import React from 'react';

export const ViewTalk = props => (
    <div className="talkie-wrapper">
    <div className="talkie-block">
        <div className='talkie-header'>
            <center>
            { props.viewing_talk.speaker }:<b>{ props.viewing_talk.title }</b>
            </center>
        </div>
        <div className='mini-header'>
            { props.viewing_talk.location }, { props.viewing_talk.date }
        </div>
        <div className="row">
        <p>
        { props.viewing_talk.abstract }
        </p>
        </div>
    </div>
    <div className="talkie-comments">
        <ul>
        <li><textarea
            rows="3"
            className="fullwidth"
            placeholder="add a comment (press return twice to submit)"
            value={props.comment}
            onChange={e => props.onChangeComment(e.target.value, props.user)}
            />
        </li>

        { props.comments.map(
            t => <li key={'comment_' + t.id}>
                    <div className='username'>{t.user}</div>
                    <div className='comment' dangerouslySetInnerHTML={{ __html: t.html }}></div>
                </li>
            )
        }
        </ul>
    </div>
    </div>
);

