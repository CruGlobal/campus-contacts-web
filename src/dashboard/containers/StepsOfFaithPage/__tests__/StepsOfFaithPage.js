// Vendors
import React from 'react';
// Project
import { renderWithContext } from '../../../testUtils';
// Subject
import StepsOfFaithPage from '../';

describe('<StepsOfFaithPage />', () => {
    it('should render properly', async () => {
        renderWithContext(<StepsOfFaithPage />).snapshot();
    });
});
