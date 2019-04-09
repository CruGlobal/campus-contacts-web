import React from 'react';
import { shallow } from 'enzyme';
import StepsInfoPersonal from './stepsInfoPersonal';

describe('<StepsInfoPersonal />', () => {
    it('should render correctly', () => {
        const component = shallow(
            <StepsInfoPersonal
                userStats={'20'}
                numberStats={'120'}
                peopleStats={'2'}
            />,
        );
       expect(component.find('Styled(p)').text()).toBe('20 members have taken 120 steps with 2 people.')
    });
});