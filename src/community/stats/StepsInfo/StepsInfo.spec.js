import React from 'react';
import { shallow } from 'enzyme';
import StepsInfo from './StepsInfo';

describe('<StepsInfo />', () => {
    it('it should render correctly', () => {
        const mock = jest.fn()
        const style = "hello";
        const component = shallow(
            <StepsInfo style={style} />,
        );
        // console.log(component.debug());
        expect(mock).toHaveBeenCalledTimes(0)
        expect(component.prop('style')).toEqual('hello')
    });
});
