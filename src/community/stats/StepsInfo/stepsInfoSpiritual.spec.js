import React from 'react';
import { shallow } from 'enzyme';
import StepsInfoSpiritual from './stepsInfoSpiritual';

describe('<StepsInfoPersonal />', () => {
    it('should render correctly', () => {
        const component = shallow(
            <StepsInfoSpiritual
                userStats={'2'}
            />,
        );
       
       expect(component.find('Styled(p)').text()).toBe('2 people reached a new stage on their spiritual journey.')
    });
});