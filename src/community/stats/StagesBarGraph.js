import React from 'react';
import { ResponsiveBar } from '@nivo/bar';
import styled from '@emotion/styled';

const Container = styled.div`
    width: 100%;
    height: 220px;
    background: white;
    margin-bottom: 30px;
    border-radius: 5px;
    > div {
        background: white;
    }
`;

const TabsLayout = styled.div`
    display: grid;
    grid-template-row: repeat(2, 1fr);
    justify-items: center;
    background: #3cc8e6;
    width: 235.5px;
    margin-left: 1px;
    height: 70px;
    color: white;
    :active {
        background: #007398;
    }
`;

const TabsEdgeL = styled(TabsLayout)`
    border-top-left-radius: 5px;
`;

const TabsEdgeR = styled(TabsLayout)`
    border-top-right-radius: 5px;
`;

const TabsContainer = styled.div`
    display: grid;
    grid-template-columns: repeat(4, 1fr);
`;

const Tabs = ({ objective, stats, edge, edgeR, edgeL }) =>
    edge ? (
        edgeR ? (
            <TabsEdgeR>
                <p>{objective}</p>
                <p>{stats}</p>
            </TabsEdgeR>
        ) : (
            <TabsEdgeL>
                <p>{objective}</p>
                <p>{stats}</p>
            </TabsEdgeL>
        )
    ) : (
        <TabsLayout>
            <p>{objective}</p>
            <p>{stats}</p>
        </TabsLayout>
    );

export const StagesBarGraph = () => (
    <Container>
        <TabsContainer>
            <Tabs edge={true} objective={'MEMBERS/PERSONAL STEPS'} stats={10} />
            <Tabs objective={'PERSONAL STEPS COMPLETED'} stats={10} />
            <Tabs objective={'MEMBER MOVEMENT'} stats={10} />
            <Tabs edgeR={true} edge={true} />
        </TabsContainer>
        <ResponsiveBar
            data={[
                {
                    stage: 'No Stage',
                    members: 10,
                    stepsAdded: 25,
                    stepsCompleted: 17,
                },
                {
                    stage: 'Not Sure',
                    members: 10,
                    stepsAdded: 34,
                    stepsCompleted: 37,
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
                    stepsAdded: 23,
                    stepsCompleted: 34,
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
                top: 30,
                right: 0,
                bottom: 30,
                left: 0,
            }}
            padding={0.2}
            innerPadding={3}
            colors={['#ECEEF2', '#3CC8E6', '#007398']}
            colorBy="id"
            fill={'white'}
            axisTop={null}
            groupMode={'grouped'}
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
