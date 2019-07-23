// Vendors
import React from 'react';

import { renderWithContext } from '../../../testUtils';
import PersonalStepsCompletedTotal from '../';

describe('<PersonalStepsCompletedTotal />', () => {
    it('should render properly loading state', async () => {
        renderWithContext(<PersonalStepsCompletedTotal />).snapshot();
    });

    // TODO: Add unit tests when communityReport is available in GraphQL schema
});
