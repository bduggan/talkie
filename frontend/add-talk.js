import React from 'react';

var TextInput = ( { placeholder, name, obj, onChange, size } ) =>
    <input
        type="text"
        placeholder={placeholder || name}
        className={"col-" + size}
        value={obj[name]}
        onChange={ e => onChange({ ...obj, [name]: e.target.value })} />

export const AddTalk = props => (
   <div className="talkie-wrapper">
       <h2>New talk</h2>
       <div className='flex-container'>
       <TextInput name="title" size="8"
            obj={props.talk} onChange={props.onChangeTalk} />
       <TextInput name="speaker" size="4"
            obj={props.talk} onChange={props.onChangeTalk} />
       </div>
       <div className='flex-container'>
       <TextInput name="location" size="8"
            obj={props.talk} onChange={props.onChangeTalk} />
       <TextInput name="date" placeholder="date (YYYY-MM-DD)" size="4"
            obj={props.talk} onChange={props.onChangeTalk} />
       </div>
       <div className='flex-container'>
       <textarea rows="5" className="col-12" placeholder="abstract"
           value={props.talk.abstract}
           onChange={e =>
               props.onChangeTalk({ ...props.talk, abstract: e.target.value })} />
       </div>
     <input type="button" value="Add talk" onClick={props.onAddTalk} />
   </div>
);


