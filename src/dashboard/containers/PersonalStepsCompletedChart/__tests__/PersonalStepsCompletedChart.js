// Vendors
import React from 'react';
import { waitForElement } from '@testing-library/react';

import { renderWithContext } from '../../../testUtils';
import PersonalStepsCompletedChart from '../';

describe('<PersonalStepsCompletedChart />', () => {
    it('should render properly loading state', async () => {
        renderWithContext(<PersonalStepsCompletedChart />).snapshot();
    });

    // TODO: Add unit tests when communityReport is available in GraphQL schema
});
