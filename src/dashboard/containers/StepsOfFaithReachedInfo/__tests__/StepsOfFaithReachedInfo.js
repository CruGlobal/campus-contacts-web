// Vendors
import React from 'react';

import { renderWithContext } from '../../../testUtils';
import StepsOfFaithReachedInfo from '../';

describe('<StepsOfFaithReachedInfo />', () => {
    it('should render properly loading state', async () => {
        renderWithContext(<StepsOfFaithReachedInfo />).snapshot();
    });
});
