// Vendors
import React from 'react';

import { renderWithContext } from '../../../testUtils';
import StepsOfFaithCompletedChart from '../';

describe('<StepsOfFaithCompletedChart />', () => {
    it('should render properly loading state', async () => {
        renderWithContext(<StepsOfFaithCompletedChart />).snapshot();
    });
});
