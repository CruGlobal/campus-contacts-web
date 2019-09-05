import React from 'react';

import { renderWithContext } from '../../../../testUtils';

import InteractionsPage from '..';

describe('<PersonalStepsPage />', () => {
    it('should render properly in loading state', async () => {
        const { snapshot, unmount } = renderWithContext(<InteractionsPage />, {
            appContext: {
                orgId: '1',
            },
        });
        snapshot();
        unmount();
    });

    // TODO: Add a test with mocking data when GraphQL schema contains above query
});
