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
        expect(component.contains('20')).toBeTruthy();
        expect(component.contains('120')).toBeTruthy();
        expect(component.contains('2')).toBeTruthy();
    });
});
