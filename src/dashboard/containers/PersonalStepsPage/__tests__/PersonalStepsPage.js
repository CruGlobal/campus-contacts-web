// Vendors
import React from 'react';
// Project
import { renderWithContext } from '../../../testUtils';
// Subject
import PersonalStepsPage from '../';

describe('<PersonalStepsPage />', () => {
    it('should render properly', async () => {
        renderWithContext(<PersonalStepsPage />).snapshot();
    });
});
