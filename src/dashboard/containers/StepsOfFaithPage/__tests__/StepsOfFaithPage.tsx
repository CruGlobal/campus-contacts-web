import React from 'react';

import { renderWithContext } from '../../../testUtils';
import StepsOfFaithPage from '../';

describe('<StepsOfFaithPage />', () => {
    it('should render properly in loading state', async () => {
        renderWithContext(<StepsOfFaithPage />, {
            appContext: {
                orgId: 1,
            },
        }).snapshot();
    });

    // TODO: Add a test with mocking data when GraphQL schema contains above query
});
