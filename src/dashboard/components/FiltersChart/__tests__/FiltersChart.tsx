import React from 'react';
import gql from 'graphql-tag';

import { renderWithContext } from '../../../testUtils';
import FiltersChart from '../';
import { GET_STEPS_COMPLETED_REPORT } from '../../../containers/StepsOfFaithPage/queries';

describe('<FiltersChart />', () => {
    it('should render properly', async () => {
        renderWithContext(
            <FiltersChart
                query={GET_STEPS_COMPLETED_REPORT}
                mapData={() => {}}
                label={'test label'}
            />,
        ).snapshot();
    });

    // TODO: Add a test with mocking data when GraphQL schema contains above query
});
