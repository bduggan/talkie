import React from 'react';
import { render } from 'react-dom';
import { createStore, applyMiddleware } from 'redux';
import { Provider, connect } from 'react-redux';
import * as Actions from './actions';
import { talkieReducer } from './reducer';
import thunkMiddleware from 'redux-thunk';
import WSAction from 'redux-websocket-action';
import { AddTalk } from './add-talk';
import { ViewTalk } from './view-talk';
import { LatestTalks } from './latest-talks';
import GitHubLogin from 'react-github-login';

const onSuccess = response => login(response.code);
const onFailure = response => console.error(response);
const client_id = 'c3e6fecfb82ebadc1aa0'

var App = props => (
    <div>
        <div className="header">
            <a href='/' class='logo'>Talkie</a>
            <div className='login'>
                { props.user ? (
                <div className='user'>
                    {props.user.name}
                    <img width="32" height="32" 
                        src={props.user.avatar_url} />
                </div>
                ) : (
                <GitHubLogin
                    clientId={client_id}
                    redirectUri="http://localhost:20000"
                    scope=""
                    onSuccess={props.onLogin}
                    onFailure={onFailure}/>
                ) }
            </div>
        </div>

        <div className="flex-container">
            <LatestTalks
                talks={props.latestTalks}
                selectTalk={props.selectTalk}
                onClearTalk={props.onClearTalk}
                viewing={props.viewing_talk}
                />
            { props.viewing_talk ?
                <ViewTalk { ...props } />
            : <AddTalk { ...props } /> }
        </div>
    </div>
);

function mapProps(state) { return state; };

function mapDispatch(dispatch) {
    return {
        onChangeTalk: talk => dispatch( Actions.editTalk(talk)),
        onAddTalk:       _ => dispatch( Actions.addTalk()),
        selectTalk:     id => dispatch( Actions.selectTalk(id,store)),
        onClearTalk:     _ => dispatch( Actions.clearTalk()),
        onChangeComment: (c,user) => dispatch( Actions.editComment(c,user)),
        onLogin:       obj => dispatch( Actions.login(obj))
    };
}

let store = createStore( talkieReducer, applyMiddleware(thunkMiddleware) );
let ConnectedApp = connect(mapProps, mapDispatch)(App)

function talkie_connect(endpoint) {
    let host = window.location.host;
    let wsAction = new WSAction(store, 'ws://' + host + '/' + endpoint, {
        retryCount: 3,
        retryInterval: 3
    });
    return wsAction;
}
let talks = talkie_connect('latest-talks');
talks.start();

render(
    <Provider store={store}>
        <ConnectedApp />
    </Provider>,
    document.getElementById('app')
);
