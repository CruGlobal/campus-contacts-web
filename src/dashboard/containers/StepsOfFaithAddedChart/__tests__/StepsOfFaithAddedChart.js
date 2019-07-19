// Vendors
import React from 'react';

import { renderWithContext } from '../../../testUtils';
import StepsOfFaithAddedChart from '../';

describe('<StepsOfFaithAddedChart />', () => {
    it('should render properly loading state', async () => {
        renderWithContext(<StepsOfFaithAddedChart />).snapshot();
    });
});
