import React from 'react';
import { ResponsiveBar } from '@nivo/bar';
import PropTypes from 'prop-types';
import styled from '@emotion/styled';

const Container = styled.div`
    width: 75%;
    height: 220px;
    margin-bottom: 30px;
    border-radius: 5px;
    > div {
        background: white;
        border-radius: 0 0 5px 5px;
    }
`;

// The Tabs at top of graph
const TabsLayout = styled.div`
    display: flex;
    flex-direction: column;
    align-item: flex-start;
    background: #3cc8e6;
    width: 99%;
    margin-left: 1px;
    height: 70px;
    font-size: 12px;
    color: white;
    > p {
        margin-left: 5px;
        margin-bottom: 0;
    }
    ::after {
        color: transparent;
        content: '';
        position: absolute;
        top: 234px;
        left: 0;
        right: 54%;
        margin: auto;
        border-bottom: 6px solid white;
        border-left: 6px solid transparent;
        border-right: 6px solid transparent;
        width: 0;
    }
`;

// Didn't know a way to define left and right rounded edges for the tabs on the graph so I have this solution for now
// Tab for left corner
const TabsEdgeL = styled(TabsLayout)`
    border-top-left-radius: 5px;
    background: #007398;
`;
// Tab for right corner
const TabsEdgeR = styled(TabsLayout)`
    border-top-right-radius: 5px;
`;

// Container holding tabs
const TabsContainer = styled.div`
    display: grid;
    grid-template-columns: repeat(4, 1fr);
`;

const TabsNumber = styled.p`
    font-size: 2rem;
`;

// Takes in objective(the tasks or step), stats(the numbers completed), edge to check if its a edge tab, and then either left or right.
// I setup a conditional statement, if its a edge than check if its the right corner tab, if not than its left corner tab.
// If its not a tab than just render a regular tab
const Tabs = ({ objective, stats, edge, edgeR, edgeL, active, props }) =>
    edge ? (
        edgeR ? (
            <TabsEdgeR>
                <p>{objective}</p>
                <TabsNumber>{stats}</TabsNumber>
            </TabsEdgeR>
        ) : (
            <TabsEdgeL>
                <p>{objective}</p>
                <TabsNumber>{stats}</TabsNumber>
            </TabsEdgeL>
        )
    ) : (
        <TabsLayout>
            <p>{objective}</p>
            <TabsNumber>{stats}</TabsNumber>
        </TabsLayout>
    );

export const StagesBarGraph = props => (
    <Container>
        <h3>PERSONAL STEPS OF FAITH</h3>
        <TabsContainer>
            {/* On click set our graph state equal to Bar */}
            <div onClick={() => props.setGraph(props.graph[0])}>
                <Tabs
                    edge={true}
                    objective={'MEMBERS/PERSONAL STEPS'}
                    stats={'20 / 40'}
                    active={true}
                />
            </div>
            {/* On click set our graph state equal to Line */}
            <div onClick={() => props.setGraph(props.graph[1])}>
                <Tabs objective={'PERSONAL STEPS COMPLETED'} stats={10} />
            </div>
            <Tabs objective={'MEMBER MOVEMENT'} stats={2} />
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
            axisTop={null}
            groupMode={'grouped'}
            axisRight={null}
            axisBottom={{
                tickSize: 0,
                tickPadding: 13,
            }}
            axisLeft={null}
            enableGridY={true}
            gridYValues={[25, 50]}
            enableLabel={false}
            animate={true}
            motionStiffness={90}
            motionDamping={15}
        />
    </Container>
);

StagesBarGraph.propTypes = {
    objective: PropTypes.string,
    stats: PropTypes.number,
};
