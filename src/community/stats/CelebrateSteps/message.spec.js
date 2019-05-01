import React from 'react';
import { shallow } from 'enzyme';
import Message from './message';

describe('<Message />', () => {
    it('Should render properly', () => {
        const information = {
            message: 'interaction',
            user: {
                fullName: "Christian Huffman",
                firstName: "Christian"
            },
            interactionType: 'Holy Spirit Presentation'
        }
        const component = shallow(<Message message={information.message} user={information.user} interactionType={information.interactionType}></Message>)
        
        expect(component.find('h3').text()).toEqual('Christian Huffman')
        expect(component.find('p').text()).toEqual('Christian has had a Holy Spirit Presentation interaction with a person.')
    })
})