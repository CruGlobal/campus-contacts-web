import React from 'react';
import { shallow } from 'enzyme';
import StepsInfo from './StepsInfo';

describe('<StepsInfo />', () => {
    it('it should render correctly', () => {

        const style = "hello";
        const component = shallow(
            <StepsInfo style={style} />,
        );
        // console.log(component.debug());
        expect(component.prop('style')).toEqual('hello')
    });
});
