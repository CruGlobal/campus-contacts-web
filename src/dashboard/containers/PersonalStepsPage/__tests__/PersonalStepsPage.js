import React from 'react';

import { renderWithContext } from '../../../testUtils';
import PersonalStepsPage from '../';

describe('<PersonalStepsPage />', () => {
    it('should render properly', async () => {
        renderWithContext(<PersonalStepsPage />).snapshot();
    });
});
