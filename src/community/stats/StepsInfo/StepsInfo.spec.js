import React from 'react';
import { shallow } from 'enzyme';
import StepsInfo from './StepsInfo';

describe('<StepsInfo />', () => {
    it('it should render correctly with StepsInfoPersonal and StepsInfoSpiritual', () => {
        const mock = jest.fn()

        const component = shallow(
            <StepsInfo />,
        );
        // console.log(component.debug());
        expect(mock).toHaveBeenCalledTimes(0)
        expect(component.find('StepsInfoPersonal')).toBeTruthy()
        expect(component.find('StepsInfoSpiritual')).toBeTruthy()
    });
});
