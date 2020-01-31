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
                nullContent={'challengesCompleted'}
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

    it('should render properly with data', async () => {
        const mapRows = () => [['cell1', 'cell2'], ['cell3', 'cell4']];
        const mapPage = () => ({});

        const { snapshot } = renderWithContext(
            <Table
                nullContent={'challengesCompleted'}
                query={GET_CHALLENGES}
                headers={['header-1', 'header-2', 'header-3']}
                mapRows={mapRows}
                mapPage={mapPage}
                variables={{ first: 5, id: 1, sortBy: 'createdAt_DESC' }}
            />,
            {
                appContext: {
                    orgId: '1',
                },
            },
        );

        await wait();
        snapshot();
    });

    it('Should render null content when no data', async () => {
        const mapRows = () => [['cell1', 'cell2'], ['cell3', 'cell4']];
        const mapPage = () => ({});

        const { snapshot } = renderWithContext(
            <Table
                nullContent={'challengesCompleted'}
                query={GET_CHALLENGES}
                headers={['header-1', 'header-2', 'header-3']}
                mapRows={mapRows}
                mapPage={mapPage}
                variables={{ first: 5, id: 1, sortBy: 'createdAt_DESC' }}
            />,
            {
                appContext: {
                    orgId: '1',
                },
                mocks: {
                    Community: () => ({
                        communityChallenges: () => ({
                            nodes: () => [],
                        }),
                    }),
                },
            },
        );

        await wait();
        snapshot();
    });
});
