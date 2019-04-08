import React from 'react';
import { mount } from 'enzyme';
import StepsInfo from './StepsInfo';

describe('<StepsInfo />', () => {
    it('it should render correctly', () => {
        const component = mount(
            <StepsInfo
                userStats={'20'}
                numberStats={'120'}
                peopleStats={'2'}
            />,
        );
        // console.log(component.debug());
        expect(component.prop('userStats')).toEqual('20')
        expect(component.prop('numberStats')).toEqual('120');
        expect(component.prop('peopleStats')).toEqual('2');
        expect(component.find('StepsInfoPersonal').text()).toEqual('20 members have taken 120 steps with 40 people.')
    });
});
