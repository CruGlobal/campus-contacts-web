import React from 'react';
import { shallow } from 'enzyme';
import DashBoardNavBar from './navBar';

describe('<DashBoardNavBar />', () => {
    it("Should render properly", () => {
        const orgID = 15878;
        
        const component = shallow(<DashBoardNavBar orgID={orgID}></DashBoardNavBar>)

        expect(component.find('h1').text()).toEqual('Org Id: 15878')

        // console.log(component.debug());
    })
})