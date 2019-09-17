import React from 'react';

import { renderWithContext } from '../../../../testUtils';

import ChallengesPage from '..';

describe('<ChallengesPage />', () => {
    it('should render properly in loading state', () => {
        const { snapshot, unmount } = renderWithContext(<ChallengesPage />, {
            appContext: {
                orgId: '1',
            },
        });
        snapshot();
        unmount();
    });

    // TODO: Add a test with mocking data when GraphQL schema contains above query
});
