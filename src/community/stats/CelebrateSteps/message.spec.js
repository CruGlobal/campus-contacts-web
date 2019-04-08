import React from 'react';
import { shallow } from 'enzyme';
import Message from './message';

describe('<Message />', () => {
    it('Should render properly', () => {
        const information = {
            message: 'Runs Fine',
            user: 'Test User'
        }
        const component = shallow(<Message message={information.message} user={information.user}></Message>)
        
        expect(component.find('h3').text()).toEqual('Test User')
        expect(component.find('p').text()).toEqual('Runs Fine')
    })
})