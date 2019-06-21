import React from 'react';

import { renderWithContext } from '../../../testUtils';
import StepsOfFaithPage from '../';

describe('<StepsOfFaithPage />', () => {
    it('should render properly', async () => {
        renderWithContext(<StepsOfFaithPage />).snapshot();
    });
});
