// Vendors
import React from 'react';

import { renderWithContext } from '../../../testUtils';
import PersonalStepsTakenInfo from '../';

describe('<PersonalStepsTakenInfo />', () => {
    it('should render properly', async () => {
        renderWithContext(<PersonalStepsTakenInfo />).snapshot();
    });
});
