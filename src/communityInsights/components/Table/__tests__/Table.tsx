import React from 'react';
import gql from 'graphql-tag';
import { waitForElement } from '@testing-library/react';

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

    // it('should render properly with data', async () => {
    //     const mapRows = () => [['cell1', 'cell2'], ['cell3', 'cell4']];
    //     const mapPage = () => ({});

    //     const { snapshot, getByText } = renderWithContext(
    //         <Table
    //             nullContent={'challengesCompleted'}
    //             query={GET_CHALLENGES}
    //             headers={['header-1', 'header-2', 'header-3']}
    //             mapRows={mapRows}
    //             mapPage={mapPage}
    //             variables={{
    //                 first: 5,
    //                 id: '1',
    //                 sortBy: 'createdAt_DESC',
    //             }}
    //         />,
    //         {
    //             mocks: {
    //                 Query: () => ({
    //                     community: () => ({
    //                         communityChallenges: () => ({
    //                             nodes: () => [],
    //                         }),
    //                     }),
    //                 }),
    //             },
    //             appContext: {
    //                 orgId: '1',
    //             },
    //         },
    //     );

    //     await waitForElement(() => getByText('header-1'));
    //     snapshot();
    // });

    it('should render with no data', async () => {
        const mapRows = () => [['cell1', 'cell2'], ['cell3', 'cell4']];
        const mapPage = () => ({});

        const { snapshot, getByText } = renderWithContext(
            <Table
                nullContent={'challengesCompleted'}
                query={GET_CHALLENGES}
                headers={['header-1', 'header-2', 'header-3']}
                mapRows={mapRows}
                mapPage={mapPage}
                variables={{
                    first: 5,
                    id: '1',
                    sortBy: 'createdAt_DESC',
                }}
            />,
            {
                mocks: {
                    Query: () => ({
                        community: () => ({
                            communityChallenges: () => ({
                                nodes: () => [],
                            }),
                        }),
                    }),
                },
                appContext: {
                    orgId: '1',
                },
            },
        );

        await waitForElement(() =>
            getByText(
                'This community does not have any challenges. Open the MissionHub mobile app and create a community challenge.',
            ),
        );
        snapshot();
    });
});
