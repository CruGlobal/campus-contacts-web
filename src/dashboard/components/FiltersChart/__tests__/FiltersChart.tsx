import React from 'react';
import gql from 'graphql-tag';

import { renderWithContext } from '../../../testUtils';
import FiltersChart from '../';

const QUERY = gql`
    query communityReport {
        communityReport {
            dayReport {
                date
                stepsWithOthersStepsCompletedCount
                communityStagesReport {
                    pathwayStage
                    stepsWithOthersStepsCompletedCount
                }
            }
        }
    }
`;

describe('<FiltersChart />', () => {
    it('should render properly', async () => {
        renderWithContext(
            <FiltersChart
                query={QUERY}
                mapData={() => {}}
                label={'test label'}
            />,
        ).snapshot();
    });

    // TODO: Add a test with mocking data when GraphQL schema contains above query
});
