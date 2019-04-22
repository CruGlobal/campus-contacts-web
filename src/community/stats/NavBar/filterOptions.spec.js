import React from 'react';
import { shallow } from 'enzyme';
import FilterOptions from './filterOption';


const filter = {
    startDate: '04/08/2019',
    endDate: '04/15/2019'
}

describe('<FilterOptions />', () => {
    it('Should render properly', () => {
        const filterClick = jest.fn()
        const component = shallow(<FilterOptions filter={filter} onFilterClick={filterClick}></FilterOptions>)
        expect(component.prop('title')).toEqual('04/08/2019 - 04/15/2019')
        component.simulate('click');
        expect(filterClick).toHaveBeenCalled();
    })
})