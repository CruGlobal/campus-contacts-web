import React from 'react';

import { renderWithContext } from '../../../testUtils';
import ChallengesPage from '../';

describe('<ChallengesPage />', () => {
    it('should render properly in loading state', async () => {
        renderWithContext(<ChallengesPage />, {
            appContext: {
                orgId: 1,
            },
        }).snapshot();
    });

    // TODO: Add a test with mocking data when GraphQL schema contains above query
});
