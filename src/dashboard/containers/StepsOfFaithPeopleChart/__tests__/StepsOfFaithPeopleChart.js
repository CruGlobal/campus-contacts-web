// Vendors
import React from 'react';

import { renderWithContext } from '../../../testUtils';
import StepsOfFaithPeopleChart from '../';

describe('<StepsOfFaithPeopleChart />', () => {
    it('should render properly loading state', async () => {
        renderWithContext(<StepsOfFaithPeopleChart />).snapshot();
    });
});
