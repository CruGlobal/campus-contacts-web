// Vendors
import React from 'react';

import { renderWithContext } from '../../../testUtils';
import StepsOfFaithCompletedSummary from '../';

describe('<StepsOfFaithCompletedSummary />', () => {
    it('should render properly loading state', async () => {
        renderWithContext(<StepsOfFaithCompletedSummary />).snapshot();
    });
});
