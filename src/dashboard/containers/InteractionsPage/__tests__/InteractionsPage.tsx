import React from 'react';

import { renderWithContext } from '../../../testUtils';
import InteractionsPage from '../';

describe('<PersonalStepsPage />', () => {
    it('should render properly in loading state', async () => {
        renderWithContext(<InteractionsPage />, {
            appContext: {
                orgId: 1,
            },
        }).snapshot();
    });

    // TODO: Add a test with mocking data when GraphQL schema contains above query
});
