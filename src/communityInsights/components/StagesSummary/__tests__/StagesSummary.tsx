import React from 'react';
import gql from 'graphql-tag';

import { renderWithContext } from '../../../../testUtils';
import StagesSummary from '..';
import { GET_TOTAL_STEPS_COMPLETED_SUMMARY } from '../../../containers/PersonalStepsPage/queries';

describe('<StagesSummary />', () => {
    it('should render properly', () => {
        const { snapshot, unmount } = renderWithContext(
            <StagesSummary
                query={GET_TOTAL_STEPS_COMPLETED_SUMMARY}
                variables={{
                    organizationId: 1,
                }}
                mapData={data =>
                    data.community.report.stagesReport.map((entry: any) => ({
                        stage: entry.stage.name,
                        icon: entry.stage.name.toLowerCase().replace(' ', '-'),
                        count: entry.personalStepsCompletedCount,
                    }))
                }
            />,
        );
        snapshot();
        unmount();
    });

    // TODO: Add a test with mocking data when GraphQL schema contains above query
});
