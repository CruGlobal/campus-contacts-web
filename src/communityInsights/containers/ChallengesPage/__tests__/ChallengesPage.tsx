import React from 'react';

import { renderWithContext } from '../../../../testUtils';
import { MockList } from 'graphql-tools';

import ChallengesPage from '..';
import { wait } from '@testing-library/react';

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

    fit('should render properly after loading', async () => {
        const { snapshot } = renderWithContext(<ChallengesPage />, {
            appContext: {
                orgId: '1',
            },
            mocks: {
                Community: () => {
                    return {
                        communityChallenges: () => ({
                            nodes: () => new MockList(1),
                        }),
                    };
                },
            },
        });

        await wait();

        snapshot();
    });
});
