import React from 'react';
import { shallow } from 'enzyme';
import StepsInfo from './StepsInfo';

describe('<StepsInfo />', () => {
    it('it should render correctly with StepsInfoPersonal and StepsInfoSpiritual', () => {
        const component = shallow(
            <StepsInfo />,
        );      
        expect(component.find('StepsInfoPersonal')).toBeTruthy()
        expect(component.find('StepsInfoSpiritual')).toBeTruthy()
    });
});
