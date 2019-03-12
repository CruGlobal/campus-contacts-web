import React from 'react';
import { ResponsiveBar } from '@nivo/bar';
import styled from '@emotion/styled';

const Container = styled.div`
    width: 100%;
    height: 220px;
`;

export const StagesBarGraph = () => (
    <Container>
        <ResponsiveBar
            data={[
                {
                    stage: 'No Stage',
                    members: 10,
                    stepsAdded: 53,
                    stepsCompleted: 10,
                },
                {
                    stage: 'Not Sure',
                    members: 10,
                    stepsAdded: 53,
                    stepsCompleted: 10,
                },
                {
                    stage: 'Uninterested',
                    members: 10,
                    stepsAdded: 53,
                    stepsCompleted: 10,
                },
                {
                    stage: 'Curious',
                    members: 10,
                    stepsAdded: 53,
                    stepsCompleted: 10,
                },
                {
                    stage: 'Forgiven',
                    members: 10,
                    stepsAdded: 53,
                    stepsCompleted: 10,
                },
                {
                    stage: 'Growing',
                    members: 10,
                    stepsAdded: 53,
                    stepsCompleted: 10,
                },
                {
                    stage: 'Guiding',
                    members: 10,
                    stepsAdded: 53,
                    stepsCompleted: 10,
                },
            ]}
            keys={['members', 'stepsAdded', 'stepsCompleted']}
            indexBy="stage"
            margin={{
                top: 10,
                right: 0,
                bottom: 50,
                left: 0,
            }}
            padding={0.2}
            colors={['#ECEEF2', '#3CC8E6', '#007398']}
            colorBy="id"
            axisTop={null}
            axisRight={null}
            axisBottom={{
                tickSize: 0,
            }}
            axisLeft={null}
            enableGridY={false}
            enableLabel={false}
            animate={true}
            motionStiffness={90}
            motionDamping={15}
        />
    </Container>
);
