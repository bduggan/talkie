import * as ActionTypes from './actions';

const InitialState = {
    talk: { title    : '',
            speaker  : '',
            abstract : '',
            location : '',
            date     : '',
            comment  : '',
    },
    user         : null,
    viewing_talk : null,
    comments     : [],
    latestTalks  : []
};

function unique_by(attr,list) {
    var seen = {}
    return list.filter( ({ [attr] : id }) => {
            seen[id] = seen[id] || 0
            return ! seen[id]++
    } )
}

export function talkieReducer(state=InitialState, action) {
    switch (action.type) {
        case ActionTypes.ADD_TALK:
            return { ...state, talk: InitialState.talk };
        case ActionTypes.EDIT_TALK:
            return { ...state, talk: action.talk };
        case ActionTypes.LATEST_TALK:
            console.log( [ action.talk, ...state.latestTalks ] );
            return { ...state,
                latestTalks: unique_by('id',[ action.talk, ...state.latestTalks ])
            }
        case ActionTypes.VIEW_TALK:
             return { ...state, comments : [], viewing_talk : action.talk }
        case ActionTypes.CLEAR_TALK:
            return { ...state, viewing_talk : null }
        case ActionTypes.LATEST_COMMENT:
            return { ...state,
                      comments : [
                                   ...state['comments'],
                                   action.comment
                      ] }
        case ActionTypes.EDIT_COMMENT:
            return { ...state, comment: action.comment }
        case ActionTypes.LOGIN:
            return { ...state, user: action.user }
        default:
            console.log('unhandled message of type', action.type);
            return state;
    }
}

