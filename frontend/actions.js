import $ from 'jquery';
import WSAction from 'redux-websocket-action';

export const ADD_TALK = 'ADD_TALK';
export const EDIT_TALK = 'EDIT_TALK';
export const LATEST_TALK = 'LATEST_TALK';
export const LATEST_COMMENT = 'LATEST_COMMENT';
export const EDIT_COMMENT = 'EDIT_COMMENT';
export const VIEW_TALK = 'VIEW_TALK';
export const CLEAR_TALK = 'CLEAR_TALK';
export const LOGIN = 'LOGIN';

export function editTalk(talk) {
    return { type: EDIT_TALK, talk }
}

export function editComment(comment,user) {
    if (comment.substr(-2) == "\n\n") {
        let trimmed = comment.substr(0,comment.length-2)
        return (dispatch, getState) => {
            $.ajax({
                url : '/talk/' + getState().viewing_talk.id + '/comments',
                type : 'POST',
                contentType : 'application/json',
                data : JSON.stringify( { msg : trimmed, user : user.name } ),
                success : () => dispatch( { type : EDIT_COMMENT, comment : '' })
            })
        }
    }
    return { type : EDIT_COMMENT, comment }
}

export function addTalk() {
    return (dispatch, getState) => {
        var talk = getState().talk;
        for (var attr of ['title','speaker','abstract']) {
            if (!talk[attr]) {
                return dispatch( { type : ADD_TALK, talk: talk, error: "missing " + attr } )
            }
        }
        $.ajax({
            url : '/talks',
            type : 'POST',
            contentType : 'application/json',
            data : JSON.stringify( talk ),
            success : () => dispatch( { type: ADD_TALK } )
        })
    }
}

let host = window.location.host;

let comments = null;

function talkie_connect2(endpoint,store) {
    let host = window.location.host;
    let wsAction = new WSAction(store, 'ws://' + host + '/' + endpoint, {
        retryCount: 3,
        retryInterval: 3
    });
    return wsAction;
}

function follow_talk(id,store) {
    console.log('getting comments for ' + id );
    if (comments) {
        console.log('stopping comments for previous selection');
        comments.stop();
    }
    console.log('connecting to latest comments for ' + id );
    comments = talkie_connect2('latest-comments/' + id, store);
    comments.start();
    // comments._socket.socket.send('{"follow" : ' + id + '}');
}


export function selectTalk(id,store) {
    console.log('called selectTalk',id);
    return (dispatch, getState) => {
        $.ajax({
            url : '/talk/' + id,
            type : 'GET',
            contentType : 'application/json',
            success : talk => {
                dispatch( { type: VIEW_TALK, talk } )
                follow_talk(id,store);
            }
        });

    }
}

export function clearTalk() {
    console.log('clearing talk');
    return { type: CLEAR_TALK, };
}

export function login(obj) {
    var code = obj.code;
    console.log('login with code', code);
    return (dispatch, getState) => {
        $.ajax({
            url : '/login',
            type : 'POST',
            contentType : 'application/json',
            data : JSON.stringify( { code : code } ),
            success : (response) => {
                console.log(response)
                // user should have access token
                var access_token = response.access_token;
                $.ajax({
                    url : 'https://api.github.com/user',
                    beforeSend: function(xhr) {
                        xhr.setRequestHeader( "Authorization", 'token ' + access_token)
                    },
                    success : (response) => {
                        console.log(response);
                        var username = response.login;
                        dispatch(
                            { type : LOGIN,
                                user: {
                                    token : response.access_token,
                                    avatar_url : response.avatar_url,
                                    name : username }
                            }
                        )
                        }
                    })
            }
        })
    }
}
