import React from 'react';
import { shallow } from 'enzyme';
import Tab from './tab';



describe('<Tab />', () => {
   
    it('should render correctly', () => {
        const component = shallow(
            <Tab active={true} title={'title'} value={'123'}  />,
        );
        
        expect(component.prop('active')).toEqual(true);
        expect(component.contains(<p>title</p>)).toBeTruthy();
        expect(component.contains('123')).toBeTruthy();
    });
});
