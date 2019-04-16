import React from 'react';
import { shallow } from 'enzyme';
import BarStatCard from './statCard';

describe('<BarStatCard />', () => {
    it('Should Render Correctly', () => {
        const Stats = {
            count: 14,
            label: 'Forgiven',
            description: 'Hello'
        }
        const component = shallow(
            <BarStatCard description={Stats.description} count={Stats.count} label={Stats.label}></BarStatCard>
        )
        
        expect(component.find('Styled(span)').at(0).text()).toBe('14');
        expect(component.find('Styled(span)').at(1).text()).toBe('Forgiven');
    })
})