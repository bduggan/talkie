import React from 'react';

export const LatestTalks = props => (
   <div className="menu">
        <ul>
        <li
            className={ props.viewing ? '' : 'selected' }
            onClick={props.onClearTalk}>New talk</li>
        {
            props.talks.map(
                t =>
                <li key={t.id}
                    onClick={_ => props.selectTalk(t.id)}
                    className={
                        props.viewing && props.viewing.id==t.id
                        ? 'selected' : ''
                    }
                >
                    <i className="speaker">
                    {t.speaker}</i>: {t.title}
                    </li>
                )
        }
        </ul>
   </div>
);


