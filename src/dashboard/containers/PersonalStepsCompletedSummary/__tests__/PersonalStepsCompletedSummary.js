// Vendors
import React from 'react';

import { renderWithContext } from '../../../testUtils';
import PersonalStepsCompletedTotal from '../';

describe('<PersonalStepsCompletedTotal />', () => {
    it('should render properly loading state', async () => {
        renderWithContext(<PersonalStepsCompletedTotal />).snapshot();
    });
});
