import React from 'react';
import { wait } from '@testing-library/react';
import { MockList } from 'graphql-tools';

import { renderWithContext } from '../../../../testUtils';
import { GET_CHALLENGES } from '../../../containers/ChallengesPage/queries';

import Table from '..';

describe('<Table />', () => {
    it('should render properly in loading', async () => {
        const mapRows = () => [['cell1', 'cell2'], ['cell3', 'cell4']];
        const mapPage = () => ({});

        const { snapshot, unmount } = renderWithContext(
            <Table
                query={GET_CHALLENGES}
                headers={['header-1', 'header-2', 'header-3']}
                mapRows={mapRows}
                mapPage={mapPage}
                variables={{}}
            />,
        );
        snapshot();
        unmount();
    });

    fit('should render properly with data', async () => {
        const mapRows = () => [['cell1', 'cell2'], ['cell3', 'cell4']];
        const mapPage = () => ({});

        const { snapshot } = renderWithContext(
            <Table
                query={GET_CHALLENGES}
                headers={['header-1', 'header-2', 'header-3']}
                mapRows={mapRows}
                mapPage={mapPage}
                variables={{ first: 5 }}
            />,
            {
                appContext: {
                    orgId: '1',
                },
                mocks: {
                    GlobalCommunity: () => ({
                        communityChallenges: () => ({
                            nodes: () => new MockList(2),
                        }),
                    }),
                },
            },
        );

        await wait();
        snapshot();
    });
});
