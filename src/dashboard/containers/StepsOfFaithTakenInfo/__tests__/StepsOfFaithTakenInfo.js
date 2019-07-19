// Vendors
import React from 'react';

import { renderWithContext } from '../../../testUtils';
import StepsOfFaithTakenInfo from '../';

describe('<StepsOfFaithTakenInfo />', () => {
    it('should render properly', async () => {
        renderWithContext(<StepsOfFaithTakenInfo />).snapshot();
    });
});
