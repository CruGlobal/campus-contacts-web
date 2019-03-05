export default {
    common: {
        select: 'Select',
        submit: 'Submit',
        yes: 'Yes',
        no: 'No',
        back: 'Back',
        goBack: 'Go Back',
        continue: 'Continue',
        ok: 'Ok',
        cancel: 'Cancel',
        choose: 'Choose',
        help: 'Help',
        became_curious: 'Became curious',
        became_open_to_change: 'Became open to change',
        engaged_disciple: 'Engaged Disciple',
        growing_disciple: 'Growing disciple',
        involved: 'Involved',
        knows_and_trusts_christian: 'Knows and trusts a Christian',
        made_decision: 'Made a decision',
        ministering_disciple: 'Ministering disciple',
        multiplying_disciple: 'Multiplying disciple',
        seeker: 'Seeker',
        seeking_god: 'Seeking God',
        address_types: {
            current: 'Current',
            emergency1: 'Emergency 1',
            emergency2: 'Emergency 2',
            permanent: 'Permanent',
        },
        application: {
            add_contact: {
                title_permission: 'Permissions',
            },
            assign_search: {
                me: 'Me',
                placeholder: "Type a person's name you want to assign to here",
            },
            interaction_types: {
                comment: 'Comment Only',
                discipleship: 'Discipleship Conversation',
                gospel_presentation: 'Personal Evangelism',
                graduating_on_mission: 'Graduating on Mission',
                holy_spirit_presentation: 'Holy Spirit Presentation',
                prayed_to_receive_christ: 'Personal Evangelism Decisions',
                spiritual_conversation: 'Spiritual Conversation',
            },
        },
        assignments: {
            assigned: 'Assigned',
            assignment: 'Assigned to',
            unassigned: 'Unassigned',
        },
        cru_status: {
            none: 'None',
            volunteer: 'Volunteer',
            affiliate: 'Affiliate',
            intern: 'Intern',
            part_time_staff: 'Part Time Field Staff',
            full_time_staff: 'Full Time Supported Staff',
        },
        contact: {
            add: 'Add',
            assigned_to: 'Assigned To',
            assigned_tos: 'Assignments',
            cru_status: 'Role',
            delete: 'Delete',
            edit: 'Edit',
            email_address: 'Email',
            first_name: 'First',
            followup_status: 'Status',
            gender: 'Gender',
            groups: 'Groups',
            labels: 'Labels',
            last_name: 'Last',
            phone_number: 'Phone',
            primary_email: 'Primary',
            primary_phone: 'Primary',
            student_status: 'Enrollment',
        },
        contacts: {
            add_contact: 'Add Contact',
            add_contact_to: 'Add Contact to {{survey}}',
            all_contacts: {
                title: 'All Contacts',
            },
            index: {
                filter: 'Search',
                for_this_permission_email_is_required:
                    "Email is required for '{{permission}}' permission.",
                for_this_permission_email_is_required_no_name:
                    'Email is required for this permission.',
                import_contacts: 'Import Contacts',
                search_contact_results_description:
                    'Please use the form to find a contact.',
                search_locate_contact_button: 'Go find',
                unassigned: 'Unassigned',
            },
            statuses: {
                uncontacted: 'Uncontacted',
            },
        },
        dashboard: {
            anonymous: {
                add: 'Add an Anonymous Interaction',
                note: 'Notes for New Anonymous',
            },
            done: 'Done',
            edit_org_order: 'Edit Organization Order',
            edit_org_order_help:
                'Want to customize your view? Press <ng-md-icon icon="editOrder"></ng-md-icon> above to reorder and hide ministries.',
            error_archiving_person:
                'Error archiving person! Please try again or contact support.',
            loading_contacts: 'Loading Contacts',
            no_contacts: {
                welcome: 'WELCOME {{name}}!',
            },
            no_contacts_help:
                'When you add a new person <ng-md-icon icon="addContact"></ng-md-icon> or someone gets assigned to you, <br> they will show up here.',
            notes_for_new_interaction: 'Notes for new',
            organizations_assigned_to_you: 'Ministries',
            people_assigned_to_you: 'People',
            report_periods: {
                one_month: '1m',
                one_week: '1w',
                one_year: '1y',
                six_months: '6m',
                three_months: '3m',
            },
            show_more: 'Show more',
            uncontacted: 'Uncontacted',
        },
        date: {
            day_names: [
                'Sunday',
                'Monday',
                'Tuesday',
                'Wednesday',
                'Thursday',
                'Friday',
                'Saturday',
            ],
        },
        error: {
            default_error_message: 'An unknown error occurred',
            messages: {
                assigned_select: {
                    search_people:
                        'Error occurred while loading the assignment choices',
                },
                bulk_message_modal: {
                    send_message: 'Error occurred while trying to send message',
                },
                bulk_transfer_modal: {
                    transfer_contacts:
                        'Error occurred while trying to transfer contacts',
                },
                edit_group_or_label_assignments: {
                    load_groups:
                        "Error occurred while loading the user's groups",
                    load_labels:
                        "Error occurred while loading the user's labels",
                },
                group_members: {
                    add_member:
                        'Error occurred while adding the person to the group',
                    load_member_chunk:
                        'Error occurred while loading the next batch of group members',
                    remove_member:
                        'Error occurred while removing the person from the group',
                },
                groups: {
                    create_group: 'Error occurred while creating the group',
                    delete_group: 'Error occurred while deleting the group',
                    load_leaders:
                        "Error occurred while loading the group's leaders",
                    update_group: 'Error occurred while updating the group',
                },
                http_proxy: {
                    default_network_error: 'An unknown network error occured',
                },
                interactions: {
                    create_interaction:
                        'Error occurred while creating the interaction',
                    delete_interaction:
                        'Error occurred while deleting the interaction',
                    update_interaction:
                        'Error occurred while updating the interaction',
                },
                labels: {
                    create_label: 'Error occurred while creating the label',
                    delete_label: 'Error occurred while deleting the label',
                    update_label: 'Error occurred while updating the label',
                },
                logged_in_person: {
                    load_user:
                        'Error occurred while loading your user information',
                },
                mass_edit: {
                    apply_mass_edit:
                        'Error occurred while mass editing the contacts',
                    load_options: 'Error occurred while loading options',
                    load_relationships: 'Error occurred while loading options',
                },
                merge_winner: {
                    load_users: 'Error occurred while loading the users',
                },
                my_people_dashboard: {
                    load_orgs: 'Error occurred while loading the organizations',
                    load_people: 'Error occurred while loading the people',
                    load_reports: 'Error occurred while loading the reports',
                    update_org_order:
                        'Error occurred while updating the organization order',
                    update_org_visibility:
                        'Error occurred while updating the organization visibility',
                },
                organization: {
                    create: 'Error occurred while create the organization.',
                    update: 'Error occurred while updating the organization.',
                    delete: 'Error occurred while deleting the organization.',
                    load_ancestry:
                        "Error occurred while loading the organization's ancestors",
                    cleanup: 'Error occurred while archviving contacts',
                    loadAll: 'Error occurred while loading your organizations',
                },
                organization_overview: {
                    load_org_relationships:
                        "Error occurred while loading the organization's groups and surveys",
                },
                organization_overview_people: {
                    load_assignments:
                        'Error occurred while loading the people assigned to these people',
                    load_org_people_count:
                        'Error occurred while loading the number of people in the organization',
                    load_people_chunk:
                        'Error occurred while loading the next batch of people',
                },
                organization_overview_suborgs: {
                    load_org_chunk:
                        'Error occurred while loading the next batch of sub-organizations',
                    load_org_suborg_count:
                        'Error occurred while loading the number of sub-organizations in the organization',
                },
                organization_overview_team: {
                    load_org_team_count:
                        'Error occurred while loading the number of team members in the organization',
                    load_team_chunk:
                        'Error occurred while loading the next batch of team members',
                },
                people_filters_panel: {
                    load_filter_stats:
                        'Error occurred while loading the filter counts',
                },
                person: {
                    archive_person: 'Error occurred while archiving the person',
                    get_contact_assignments:
                        'Error occurred while loading load the people this person is assigned to',
                    search: 'Error loading search results',
                },
                person_page: {
                    create_person: 'Error occurred while creating the person',
                    delete_avatar:
                        'Error occurred while removing the profile picture',
                    upload_avatar:
                        'Error occurred while uploading the profile picture',
                },
                person_profile: {
                    delete_relationships:
                        'Error occurred while updating the person',
                    reload_merged_person:
                        'Error occurred while refreshing the person',
                    update_person: 'Error occurred while updating the person',
                },
                preferences_page: {
                    update_preferences:
                        'Error occurred while updating the preferences',
                },
                progressive_list_loader: {
                    load_chunk: 'Error occurred while loading the items',
                },
                reports: {
                    load_org_reports:
                        "Error occurred while loading the organization's reports",
                    load_person_report:
                        "Error occurred while loading the person's report",
                },
                routes: {
                    get_history:
                        "Error occurred while loading the person's history",
                    get_organization:
                        'Error occurred while loading the organization',
                    get_person: 'Error occurred while loading the person',
                    get_survey: 'Error occurred while getting survey data',
                },
                surveys: {
                    loadQuestions:
                        'Error occurred while loading survey questions',
                },
                surveyResponses: {
                    loadQuestions: 'Error loading survey questions',
                },
                template_request: {
                    load_template: 'Error occurred while loading the page',
                },
                requestAccess: 'Error occurred while processing your request',
                inviteLink: {
                    loadRemeberToken:
                        'Error occurred while loading invite information',
                    mergeAccount: 'Error occurred while merging your accounts',
                },
                signature_request:
                    'Error occurred, the agreement could not be processed',
                impersonate_request: 'Error occurred, impersonation failed',
            },
            retry_instructions: 'Click to retry',
        },
        followup_status: {
            attempted_contact: 'Attempted Contact',
            completed: 'Completed',
            contacted: 'Contacted',
            do_not_contact: 'Do Not Contact',
            uncontacted: 'Uncontacted',
            archived: 'Archived',
        },
        student_status: {
            not_student: 'Not currently a student',
            middle_school: 'Middle School',
            high_school: 'High School',
            collegiate: 'Collegiate',
            masters_or_doctorate: 'Masters/Doctorate',
        },
        general: {
            add: 'Add',
            address: 'Address',
            address_type: 'Address Type',
            address1: 'Address 1',
            address2: 'Address 2',
            address3: 'Address 3',
            address4: 'Address 4',
            city: 'City',
            country: 'Country',
            archive: 'Archive',
            cancel: 'Cancel',
            close: 'Close',
            loading_more: 'Loading more...',
            message: 'Message:',
            ok: 'OK',
            save: 'Save',
            send: 'Send',
            state: 'State',
            subject: 'Subject:',
            zip: 'Zip',
            female: 'Female',
            male: 'Male',
            other: 'Other',
            none: 'None',
            required: 'Required',
            help: 'Help',
            delete: 'Delete',
        },
        group: 'Group',
        groups: {
            confirm_delete_group:
                'Are you sure you want to delete "{{group_name}}"?',
            edit: {
                edit_group: 'Editing {{group}}',
            },
            form: {
                from: 'From',
                meets_on: 'On',
                to: 'To',
            },
            index: {
                group_name: 'Group Name',
            },
            members: {
                columns: {
                    name: 'Contacts',
                },
                contacts: 'contacts',
                leader: 'Leader',
                remove_confirm:
                    'Are you sure you want to this member from the group?',
                subtitle: 'Members of "{{group_name}}"',
                title: 'Group Members',
            },
            new: {
                new_group: 'Create a New Group',
            },
            show: {
                leaders: 'Group Leaders',
                location: 'Location',
                meets: 'Meets',
            },
        },
        interactions: {
            delete_confirmation:
                'Are you sure you want to delete this interaction?',
        },
        label: 'Label',
        labels: {
            delete: {
                confirm:
                    'Are you sure you want to delete the "{{label_name}}" label?',
            },
            edit: {
                edit_label: 'Edit Label',
            },
            index: {
                label_name: 'Name',
            },
            new: {
                new_label: 'Create a New Label',
            },
        },
        login: {
            login: 'Log in',
            login_with_key: 'Log in with The Key',
            login_with_facebook: 'Log in with Facebook',
            invite_in_progress: 'Please login to finish your invite.',
        },
        requestAccess: {
            title: 'Request Access',
            createdMissionHubBlurb:
                'MissionHub was created by Cru to help non-profit ministries stay connected with all of the leaders, members and outreach within their movement.',
            requestAccessBlurb:
                'Request access and our spectacular support team will help you get started.',
            form: {
                firstName: 'First Name',
                lastName: 'Last Name',
                organizationName: 'Organization Name',
                email: 'Email',
                submit: 'Request Access',
            },
            success: {
                thankYou: 'Thank you',
                message: 'We received your request and will contact you soon.',
                otherApps:
                    'Check out Cru’s other apps that help you connect and share your faith with the people you care about most.',
                vistitWebsite: 'Visit our Website',
            },
        },
        mergeAccount: {
            loggedInAs:
                'You are current logged in as {{fullName}} <{{email}}>.',
            continue: 'Do you want to continue?',
            mergeAccount:
                'Yes, merge {{fullName}} <{{username}}> into my account.',
            cancelMerge: 'No, I want to login to my own account.',
            successAccountMerged:
                'Congratulations, you have successfully merged {{oldAccountFullName}} <{{oldAccountUsername}}> into {{mergedAccountFullName}} <{{mergedAccountEmail}}>.',
            continueAccountMerged: 'Continue to your new ministry',
            inviteLinkExpiredTitle:
                'Sorry, the invite link has expired or is no longer valid.',
            inviteLinkExpiredMessage:
                'Please try again. If the problem persists contact MissionHub <a href="mailto:support@missionhub.com">support</a>.',
            continueAfterError: 'Continue to MissionHub',
        },
        impersonation: {
            loading: 'Please wait...',
        },
        authLanding: {
            title: 'SUCCESS!',
            thanksForVerifying:
                'Hi, so it is you! Thanks for verifying your new MissionHub account.',
            allSet: "You're all set to Sign In on your mobile app.",
            excitedForYouToGrow:
                "We're excited for you to grow closer to God by helping others experience him.",
        },
        leader: 'Leader',
        mass_edit: {
            save: 'Edit {{contactCount}} contacts',
            title: 'Edit Contacts',
            unchanged: 'Unchanged',
        },
        member: 'Member',
        messages: {
            email_title: 'Email Contacts',
            email_subtitle: 'Send an email to {{recipients}}.',
            sms_title: 'Text Contacts',
            sms_subtitle: 'Send a text message to {{recipients}}.',
            length_limit: '{{remaining_characters}} characters left',
            recipients: {
                contacts: '{{contact_count}} contacts',
                organization: 'in organization "{{name}}"',
                search: 'matching "{{search}}"',
                groups: 'in groups "{{names}}"',
                labels: 'with labels "{{names}}"',
                assigned_tos: 'assigned to "{{names}}"',
                exclusions: 'except "{{names}}"',
            },
        },
        ministries: {
            groups: {
                columns: {
                    leaders: 'Leader(s)',
                    location: 'Location',
                    name: 'Groups ({{group_count}})',
                    time: 'Meeting Time',
                },
                header: 'Groups',
                meeting_time: {
                    monthly: 'Monthly on the {{day}} from {{time}}',
                    sporadically: 'Sporadically',
                    time_range: '{{start}} - {{end}}',
                    weekly: 'Weekly on {{day}}s {{time}}',
                },
                ordinal_suffixes: ['th', 'st', 'nd', 'rd'],
            },
            labels: {
                columns: {
                    name: 'Label Name',
                },
            },
            cleanup: {
                title: 'Organization Cleanup',
                description:
                    "People are messy — and so are databases. Every year your database gets clogged up with people who may have come to a meeting once upon a time, or filled out a survey once, but never got involved and don't intend to. If you are a campus ministry, you will also have a good number of people who graduate from your ministry each year. How do you get your database trimmed up and ready for the fall? <br><br> An annual clean up can help! Simply walk through one of the steps below once a year (or however often you want) and MissionHub will again be a well-oiled machine, ready to help you transform the world!",
                archive_alumni: 'Archive Alumni',
                archive_alumni_description:
                    'Go to the Contacts screen, select the people who have graduated from your ministry and label them a "Alumni". If your ministry hasn\'t created that label yet, you can do so by adding it in Manage Labels under Tools. ',
                archive_by_date: 'Archive by date',
                archive_by_date_description:
                    'Archive contacts who have been added before:',
                archive_by_inactivty: 'Archive by inactivty',
                archive_by_inactivty_description:
                    'Archive people who have been inactive since:',
                open_contacts: 'Open Contacts',
                success_message: 'Your contacts have been archived!',
                success_title: 'You Rock!',
                success_cta: 'Take Me Home',
            },
            people: {
                activity: {
                    header: 'Activity',
                },
                archive_hover: 'Archive the selected contacts',
                archive_people_confirm:
                    'Are you sure you want to archive {{contact_count}} contacts?',
                assigned: {
                    header: 'Assigned',
                },
                clear_selection_hover: 'Unselect all of the selected contacts',
                delete_hover: 'Delete the selected contacts',
                delete_people_confirm:
                    'Are you sure you want to delete {{contact_count}} contacts?',
                email_hover: 'Email the selected contacts',
                export_hover: 'Export the selected contacts as CSV',
                gender: 'M/F',
                female: 'F',
                male: 'M',
                other: 'O',
                none: '-',
                header: 'Contacts',
                history: {
                    all: 'All',
                    anonymous: 'Anonymous',
                    header: 'History',
                    interactions: 'Interactions',
                    me: 'Me',
                    note_for_interaction: 'Note for {{interaction}}',
                    notes: 'Notes',
                    surveys: 'Surveys',
                },
                leaders: 'leaders',
                mass_edit_hover: 'Mass edit the selected contacts',
                name: 'Name',
                profile: {
                    header: 'Profile',
                },
                remove_self_confirm:
                    'You are removing yourself. If you continue, you will no longer have access to this ministry.',
                selected_contacts: '{{contactCount}} contacts selected',
                sms_hover: 'Text the selected contacts',
                status: 'Status',
                transfer_hover:
                    'Transfer the selected contacts to another organization',
                lastSurvey: 'Last Survey',
            },
            roots: 'Ministries',
            suborgs: {
                header: 'Ministries',
            },
            surveyResponses: {
                header: 'Survey Responses',
                editSurveyResponse: 'Edit Survey Response',
            },
            surveys: {
                header: 'Surveys',
                typeform: {
                    header: 'MissionHub now integrates with Typeform!',
                    subheader:
                        'Get more creative with your surveys using Typeform while driving your ministry forward with MissionHub.',
                    step1:
                        'Sign up for an account at <a href="https://typeform.com" target="_blank">typeform.com</a>.',
                    step2:
                        ' Create a new form there in Typeform - be sure you have a question on the new form asking for their "first name". Then go to the "Connect" tab followed by the "Webhooks" sub tab.',
                    step3:
                        'Copy the MissionHub URL below into the Destination URL field on Typeform.',
                    step4:
                        'Click "test webhook". You should see a green checkmark under recent requests. A new survey with a test submission should be visible in MissionHub.',
                    step5:
                        'Next to the webhooks title click the slider to enable webhooks.',
                    conclusion:
                        'Future form submissions for this survey will be sent to MissionHub automatically.',
                    missionHubUrl: 'MissionHub URL',
                    copy: 'Copy URL',
                    copied: 'URL copied to clipboard',
                },
            },
            team: {
                header: 'Team',
            },
            tools: {
                header: 'Tools',
            },
        },
        monthly: 'Monthly',
        nav: {
            about: {
                copyright: 'Copyright',
                title: 'About MissionHub',
            },
            cleanup: 'Organization Cleanup',
            contacts: 'Contacts',
            email_us: 'Email Us',
            groups: 'Groups',
            logout: 'Sign Out',
            login: 'Sign In',
            requestAccess: 'Request Access',
            manage: 'Manage Ministries',
            my_profile: 'My Profile',
            powered_by_cru: 'Powered by Cru',
            report_movement_indicators: 'Report Movement Indicators',
            search: {
                in: 'in',
            },
            preferences: 'Preferences',
            support: 'Support',
            terms: 'Terms of Service',
            copyright: 'Copyright {{ year }} Cru. All Rights Reserved.',
            warning: {
                title: 'Warning',
                body:
                    'These tools will be removed when we shut down Legacy. We are working to bring you a better dashboard experience in the near future!',
            },
        },
        organizations: {
            manage: 'Manage Ministries',
            new: 'New Ministry',
            edit: 'Edit Ministry',
            name: 'Ministry Name',
            type: 'Type',
            type_help:
                'This is how you want to identify this specific ministry. Some people use church, group, or team.',
            show_sub: 'Show Sub-Ministries',
            sub_help:
                'Checking this box allows any of the sub-ministries to appear for any involved team member when navigating MissionHub.',
            none_found: 'No ministries found',
            deleteConfirmModal: {
                title: 'Are you sure you want to delete "{{org_name}}"?',
                description:
                    'This will remove access to interactions, assignments and contacts from any of the sub-ministries.',
            },
            cleanup: {
                confirm_archive:
                    'Are you sure you wanted to archive the desired contacts?',
            },
        },
        people: {
            edit: {
                cancel_create_confirm:
                    'Are you sure you want to discard this unsaved contact?',
                delete_address_confirm:
                    'Are you sure you want to delete this address?',
                delete_email_confirm:
                    'Are you sure you want to delete this email address?',
                delete_phone_confirm:
                    'Are you sure you want to delete this phone number?',
            },
            index: {
                add_address: 'Add Address',
                create_address: 'Create Address',
                edit_address: 'Edit Address',
                labels: 'Labels',
                manage_groups: 'Manage Groups',
                manage_labels: 'Manage Labels',
            },
            search: {
                search_placeholder:
                    'Search for the first name, last name or email.',
            },
            show: {
                apply_labels: 'Apply the following labels to {{name}}.',
                apply_labels_undefined:
                    'Apply the following labels to this person.',
                apply_groups: 'Assign {{name}} to the following groups.',
                apply_groups_undefined:
                    'Assign this person to the following groups.',
                no_groups: 'No groups assigned.',
                no_labels: 'No labels assigned.',
            },
        },
        permissions: {
            admin: 'Admin',
            no_permissions: 'No Permissions',
            user: 'User',
        },
        person_multiselect: {
            no_search_results:
                'No {{people_description}} found matching "{{search}}"',
            search_placeholder: 'Search {{people_description}}',
            searching: 'Searching {{people_description}}...',
        },
        search: {
            assignments: {
                title: 'Assigned To',
            },
            groups: {
                title: 'Groups',
            },
            labels: {
                title: 'Labels',
            },
            status: {
                title: 'Status',
            },
            gender: {
                title: 'Gender',
            },
            questions: {
                title: 'Survey Questions',
            },
            sidebar: {
                include_archived: 'Include archived contacts',
            },
        },
        signatures: {
            clear: 'Clear filters',
            title: 'Signatures',
            agreements: {
                accept: 'Accept',
                decline: 'Decline',
                button: 'Continue to the MissionHub App',
                accepted: {
                    message: 'Thank you! You may now use MissionHub.',
                },
                declined: {
                    title: 'You have declined!',
                    mainBlurb:
                        'Admins will need to accept the Code of Conduct and Statement of Faith before proceeding to MissionHub. Please talk this over with your local staff and student leadership.',
                    requestAccessBlurb:
                        'You will need to request access again after having this discussion.',
                },
                codeOfConduct: {
                    title: 'Code of Conduct',
                    text:
                        '<p><b>Power to Change seeks to glorify God by making a maximum contribution toward helping to fulfill the Great Commission in Canada and around the world by developing movements of evangelism and discipleship. As the person and work of Jesus Christ is central to our mission, I desire Jesus Christ to be in the center of my life and want to honour and please Him by the way I conduct myself, thus validating the gospel of Christ and contributing to the mission. (Col. 1:10) As a follower of Jesus Christ I am committed to obeying the Great Commandment to love God with all my heart, soul and mind and to love my neighbour as myself (Matt. 22:36-40). This will involve the following:</b></p><p><b>• Growing in Christlikeness:</b> I commit to growing in personal holiness of life characterized by honesty, truthfulness and generosity, maintaining the highest ethical standards (1 Peter 1:14-16). I commit to having the attitude of Christ in showing compassion, demonstrating humility and patience, forgiving others and considering the interests of others ahead of my own (Phil. 2:1-5; Col. 3:12-14).</p><p><b>• Practising Respect and Love for others:</b> As a representative of God’s love for people, I commit to treating others with love, respect, and regard for their value and dignity as persons. I will handle my relationships with integrity and maturity, keeping in mind my responsibility as a role model (1 Tim. 4:12), and making lifestyle choices with consideration for those around me (Rom. 14; 1 Cor. 10:23-33). I renounce all forms of hate, malicious behaviour, and harassment of others, and I will practice welcoming and respectful treatment to all people regardless of background, identity, and orientation which may be different from my own. (Eph. 5:1, 2; Titus 3:2) I will respect the sanctity of life at all stages (Psalm 139:13, 14).</p><p><b>• Living a life of faith:</b> I commit myself to relying upon God for His grace to meet every need (2 Cor. 12:9; Phil. 4:19) and living in dependence upon the Holy Spirit in my daily life and ministry (Gal. 5:16, Eph. 5:18-21).</p><p><b>• Evangelism and Discipleship:</b> I commit myself to present the gospel of Jesus Christ to people in my sphere of influence and beyond, encouraging them to become disciples of Christ through the direction and empowerment of the Holy Spirit (Mark 16:15; Acts 1:8).</p><p><b>• Serving others:</b> I commit to following Jesus by serving the people I lead and work with (Matt. 20:25-28; John 12:14-15).</p><p><b>• Stewardship:</b> I commit to honouring God with my body, as my body is the temple of the Holy Spirit (1 Cor. 6:19,20). I will make choices that build up my emotional,mental and physical health and will strive for purity of thought and respectful modesty (Phil. 4:8; 1 Tim. 2:9-10). I will abstain from drunkenness, illegal or mind-altering substances, unless prescribed by a physician, as well as abstaining from the habitual use of tobacco. I commit to reserving sexual expressions of intimacy for marriage, a sacred covenant between one man and one woman (Mark 10:6-9; Heb. 13:4).</p><p><b>• Community:</b> I commit myself to meeting with other believers in a local church on a regular basis, edifying others and growing together as a caring community of followers of Christ (Heb. 10:24-25).</p><p><b>I am in agreement with and hereby commit myself to this Code of Conduct, depending upon the Holy Spirit to guide and empower me.</b></p>',
                },
                statementOfFaith: {
                    title: 'Statement of Faith',
                    text:
                        "<p><b>The sole basis of our beliefs is the Bible, God's inerrant written Word, the 66 books of the Old and New Testaments. We believe that it was uniquely, verbally and fully inspired by the Holy Spirit, and that it was written without factual error in the original manuscripts. It is the supreme and final authority in all matters on which it speaks.</b></p><p><b>We accept those large areas of doctrinal teaching on which, historically, there has been general agreement among all true Christians. Because of the specialized calling of our movement, we desire to allow for freedom of conviction on other doctrinal matters, provided that any interpretation is based upon the Bible alone, and that no such interpretation shall become an issue which hinders the ministry to which God has called us. We explicitly affirm our belief in basic Bible teachings as follows:</b></p><p><b>1.</b> There is one true God, eternally existing in three persons—the Father, Son and Holy Spirit—each of whom possesses equally all the attributes of Deity and the characteristics of personality.</p><p><b>2.</b> Jesus Christ is God, the living Word, who became flesh through His miraculous conception by the Holy Spirit and His virgin birth. Hence, He is perfect Deity and true humanity united in one person forever.</p><p><b>3.</b> He lived a sinless life and voluntarily atoned for our sins by dying on the cross as our substitute, thus satisfying divine justice and accomplishing salvation for all who trust in Him alone.</p><p><b>4.</b> He rose from the dead in the same body, though glorified, in which He had lived and died.</p><p><b>5.</b> He ascended bodily into heaven and sat down at the right hand of God the Father, where He, the only mediator between God and mankind, continually makes intercession for His own.</p><p><b>6.</b> We were originally created in the image of God. We sinned by disobeying God; thus, we were alienated from our Creator.That historic fall brought all mankind under divine condemnation.</p><p><b>7.</b> Our nature is corrupted, and we are thus totally unable to please God. Every person is in need of regeneration and renewal by the Holy Spirit.</p><p><b>8.</b> Our salvation is wholly a work of God's free grace and is not the work, in whole or in part, of human works or goodness or religious ceremony. God imputes His righteousness to those who put their faith in Christ alone for their salvation, and thereby justifies them in His sight.</p><p><b>9.</b> It is the privilege of all who are born again of the Spirit to be assured of their salvation from the very moment in which they trust Christ as their Saviour. This assurance is not based upon any kind of human merit, but is produced by the witness of the Holy Spirit, who confirms in the believer the testimony of God in His written Word.</p><p><b>10.</b> The Holy Spirit has come into the world to reveal and glorify Christ and to apply the saving work of Christ to men and women. He convicts and draws sinners to Christ, imparts new life to them, continually indwells them from the moment of spiritual birth and seals them until the day of redemption. His fullness, power and control are appropriated in the believer's life by faith.</p><p><b>11.</b> We, as believers, are called to live in the power of the indwelling Spirit so that we will not fulfill the lust of the flesh but will bear fruit to the glory of God.</p><p><b>12.</b> Jesus Christ is the Head of the Church, His Body, which is composed of all men and women, living and dead, who have been joined to Him through saving faith.</p><p><b>13.</b> God admonishes His people to assemble together regularly for worship, for participation in ordinances, for edification through the Scriptures and for mutual encouragement.</p><p><b>14.</b> At physical death the believers enter immediately into eternal conscious fellowship with the Lord, and await the resurrection of their bodies to everlasting glory and blessing.</p><p><b>15.</b> At physical death the unbelievers enter immediately into eternal conscious separation from the Lord and await the resurrection of their bodies to everlasting judgment and condemnation.</p><p><b>16.</b> Jesus Christ will come again to the earth—personally, visibly and bodily—to consummate history and the eternal plan of God.</p><p><b>17.</b> The Lord Jesus Christ commanded all believers to proclaim the gospel throughout the world and to disciple men and women of every nation. The fulfillment of that Great Commission requires that all worldly and personal ambition be subordinated to a total commitment to \"Him who loved us and gave Himself for us.\"</p><p><b>Without mental reservation, I hereby subscribe to the above statements and pledge myself to help fulfil the Great Commission in our generation, depending upon the Holy Spirit to guide and empower me.</b></p>",
                },
            },
            downloadCsv: 'Download Csv',
            grid: {
                dateSigned: 'Date Signed',
                firstName: 'First Name',
                lastName: 'Last Name',
                codeOfConduct: 'Code of Conduct',
                statementOfFaith: 'Statement of Faith',
                notAccecptedYet: 'Not Accepted Yet',
                organization: 'Organization',
                accepted: 'Accepted',
                declined: 'Declined',
                notFound: 'No Signatures found',
                loading: 'Loading...',
            },
            searchPlaceholder: 'Search',
        },
        sporadically: 'Sporadically',
        transfer: {
            options: {
                copy_answers: 'Copy survey answers with contact',
                copy_contact: 'Leave a copy of the contact in the organization',
                copy_interactions: 'Copy interactions with contact',
            },
            organizations: 'organizations',
            subtitle:
                'Transfer {{contact_count}} contact(s) to another organization.',
            title: 'Transfer Contacts',
            transfer: 'Transfer {{contact_count}} Contact(s)',
        },
        weekly: 'Weekly',
    },
    surveyTab: {
        createSurvey: 'Create Survey',
        copySurvey: 'Copy Survey',
        searchMinistry: 'Search Ministry',
        surveyName: 'Survey Name',
        columns: {
            survey: 'Survey',
            contacts: 'Contacts',
            unassigned: 'Unassigned',
            uncontacted: 'Uncontacted',
            keyword: 'Keyword',
            link: 'Link',
            status: 'Status',
            typeform: 'Typeform',
        },
        status: {
            live: 'Live',
            off: 'Off',
        },
        menu: {
            edit: 'Edit',
            preview: 'Preview',
            delete: 'Delete',
            copy: 'Copy',
            import: 'Import Survey Results',
            mass: 'Mass Entry',
        },
        errors: {
            createSurvey: 'Error occurred while creating survey',
            updateSurvey: 'Error occurred while updating survey',
            deleteSurvey: 'Error occurred while deleting survey',
            getStats: 'Error occurred while retrieving survey stats',
            addSurveyQuestion: 'Error occurred while adding survey question',
        },
    },
    phoneNumbers: {
        validations: {
            notFound: 'Your survey submission could not be found',
            inactiveOrInvalid:
                'Your survey submission is inactive or your link is invalid.',
        },
    },
    surveys: {
        preview: 'Preview this survey',
        publicView: {
            preview: {
                header: 'This is a preview.',
                inactive: 'The survey you are viewing is inactive.',
                description:
                    'While in preview mode, you cannot submit survey responses.',
            },
            post_survey_message:
                'Thanks! Your survey has been successfully submitted.',
            surveyNotFound: 'This survey could not be found',
            inactiveOrInvalid:
                'The survey you are trying to view is inactive or your link is invalid.',
        },
        delete: {
            confirm: 'Are you sure you want to delete this survey?',
        },
        settings: {
            settings: 'Settings',
            welcome_message: 'Welcome Message',
            success_message: 'Success Message',
            image: 'Image',
            image_upload: 'Upload Image',
            image_delete: 'Delete Image',
            image_delete_confirm: 'Are you sure you want to delete this image?',
            validate_phone_number: 'Validate Phone Number',
            validate_phone_number_hint:
                'If the person filling out your survey provides a phone number MissionHub can send them an SMS with a short link for them to validate their phone number.',
            validation_message: 'Validation Message',
            validation_message_hint:
                'This message will be sent via SMS with a short link.',
            validation_message_help:
                'You can use the %{first_name} template and MissionHub will automatically substitute their first name in place. A short link will be appended to this message they will need to click on!',
            validation_success_message: 'Validation Success Message',
            validation_success_message_hint:
                'When they visit the short link in the SMS this message will be shown.',
        },
        keyword: {
            keyword: 'Keyword',
            keyword_example: 'Example: Cookies',
            instructions:
                'Use at least 3 letters (no special characters/spaces)',
            help:
                'Choosing a keyword for your community or event enables you to have people fill out your survey questions via the web, interactive texting, and smartphones.\n' +
                'They will text your keyword to the number 85005 and your survey questions will appear on their device. Note: The process of acquiring new keywords requires manual intervention.\n' +
                'Once you request your keyword expect to wait up to 24 hours before we notify you via email that your keyword is approved and ready for use.',
            purpose: 'Keyword Purpose',
            purpose_instructions: 'What do you plan to use the keyword for?',
            purpose_example: 'Example: Weekly Meeting',
            response: 'Text Response',
            response_instructions: 'Response must include {{ link }} exactly.',
            response_help:
                "When someone texts in the keyword, this is the message they will receive. The {{ link }} will automatically be replaced with a link to the survey. If you want to include a link to your specific website, don't include it here.",
            response_example:
                'Example: Thanks for taking our survey! Reply with “i” or press {{ link }} if you have a smartphone.',
            request: 'Request Keyword',
            requested: 'Keyword Requested',
            requested_message:
                'We will notify you within 24 hours by email if/when your keyword is approved and ready for use.',
            errors: {
                requestKeyword: 'Error occurred while requesting a keyword',
                deleteKeyword: 'Error occurred while deleting a keyword',
                missingKeyword: 'A keyword is required',
                missingPurpose: 'A keyword purpose is required',
                missingTextResponse: 'A text response is required',
            },
            delete: {
                confirm: 'Are you sure you want to delete this keyword?',
            },
        },
        questions: {
            questions: 'Questions',
            type: 'Type',
            sort: 'Sort',
            columnTitle: 'Column Title',
            labelPlaceholder: '[Enter question here.]',
            newAnswer: 'New Answer',
            addPredefinedQuestion: 'Add Predefined/Previously Used Question',
            addNewQuestion: 'Add New Question',
            predefinedQuestions: 'Predefined Questions',
            previouslyUsedQuestions: 'Previously Used Questions',
            delete_confirm: 'Are you sure you want to delete this question?',
            initiateAssignment: 'Answers to initiate assignment/notifications',
            autoAssign: 'Auto Assign',
            autoNotify: 'Auto Notify',
            sendNotificationsViaEmail: 'Send notifications via email',
        },
    },
    contact_import: {
        step_1: {
            title: 'Select Survey and Upload CSV File',
            select_survey: 'Select Survey',
            create_survey: 'Create a new survey',
            instructions:
                'Select a survey to import your contacts from the drop down menu below.',
            instructions_b: "if you don't have a survey to import contacts to.",
            upload: 'Upload CSV File',
            select: 'Select CSV File',
            rowCount: '{{count}} rows',
            rowCount_plural: '{{count}} rows',
            parseErrors: {
                summary: 'Warning: There were some issues parsing your CSV',
                message:
                    'Please review these issues we encountered while parsing your CSV file. You may try and continue but be aware that some data may not match up with columns you expect.',
                note: 'Note: Row and Character position both start at 1.',
                row: 'CSV Row',
                characterPos: 'Character position in row',
                error: 'Error Message',
            },
            fileTypeError: 'You must select a CSV file.',
        },
        step_2: {
            title: 'Match Columns',
            instructions:
                'Match the column headings from your CSV file with the corresponding questions/column headers in the dropdown boxes.',
            csv_column: 'CSV Column',
            preview: 'Preview Row {{current}} of {{max}}',
            question_column: 'Question Column/Answer',
            do_not_import: 'Do Not Import',
            loadingQuestions: 'Loading Questions...',
        },
        step_3: {
            title: 'Add Labels to New Contacts',
            instructions:
                "You are almost ready to upload {{count}} new contacts! Use the list below to select any additional labels for these contact, or you can create a new one. When you're done, click Import.",
            labels: 'Labels',
            add_label: 'Add Label',
        },
        step_4: {
            title: 'You Rock!',
            instructions:
                'Your CSV upload is now being processed. You will receive an email when it finishes.',
            home: 'Take Me Home',
        },
        errors: {
            bulkImport:
                'Error occurred while importing contacts from your CSV file',
            save: 'Error occurred while saving contact',
        },
    },
    userPreferences: {
        title: 'User Preferences',
        language: 'Language',
        notificationsHeader: 'Let me know...',
        enabledByDefault: '(Enabled by default)',
        personTransferred:
            'When a person is transferred to one of my organizations',
        personAssigned: 'When a person is assigned to me',
        weeklyDigest: 'Weekly Ministry Digest',
    },
    peopleScreen: {
        filterSearchPlaceholder: 'Search answers',
        answerMatchingOptions: {
            exactly: 'Exactly',
            contains: 'Contains',
            doesNotContain: 'Does not contain',
            noResponse: 'No response',
            anyResponse: 'Any response',
        },
    },
    movementIndicators: {
        title: 'Report Movement Indicators',
        suggestedActions: {
            title: 'Suggested Movement Indicator Actions',
            subtitle:
                'These suggestions are designed to reinforce the proper labeling of contacts for the Involved, Engaged Disciple, and Leader categories, which will be reported on the next page.',
            loading: 'Loading suggestions…',
            newSuggestions: 'New Suggestions ({{num}})',
            previousSuggestions: 'Previous Suggestions ({{num}})',
            applyAll: 'Apply All',
            reasonPhrases: {
                spiritualConversation:
                    'had a spiritual conversation with someone.',
                gospelPresentation: 'shared the gospel with someone.',
                groupMembership: 'was added to a group.',
                groupLeader: 'became a group leader.',
                leader: 'was labeled as a leader.',
                engagedDisciple: 'was labeled as an engaged disciple.',
            },
            applyLabel:
                'Apply the <strong>&quot;{{label}}&quot;</strong> label?',
            errorLoadingSuggestedActions:
                'Error occurred while loading the suggested actions',
            errorSavingSuggestedActions:
                'Error occurred while saving the suggested actions',
        },
        confirmIndicators: {
            title: 'Confirm Movement Indicators',
            loading: 'Loading movement indicators…',
            submittedInLastWeek: {
                heading:
                    'Movement Indicators for this ministry are up to date.',
                description:
                    'Movement Indicators have been submitted for the past week. Please check back next week to submit these again.',
                descriptionContinued:
                    "If you'd like to change any numbers previously submitted, please do so in Infobase.",
            },
            interactionsHeading:
                'The pre-filled numbers below are a compilation of all activity in MissionHub within the date range specified. Any activity recorded between the end date and today will not be reflected below.',
            labelsHeading:
                'The pre-filled label indicators below display the most recently entered information. If these numbers have changed, feel free to update them below. These numbers will appear consistently week-to-week.',
            errorLoadingIndicators:
                'Error occurred while loading movement indicators to pre-fill fields',
            errorSavingIndicators:
                'Error occurred while saving movement indicators',
        },
        interactions: {
            title: 'Interactions',
            spiritualConversations: {
                label: 'Spiritual Conversations',
                tooltip:
                    'How many Spiritual Conversations have you engaged in whether you did or did not present the gospel and bring them to a point of decision. (Each time you engage the same person count it.)',
            },
            personalEvangelism: {
                label: 'Personal Evangelism',
                tooltip:
                    'How many gospel presentations through personal evangelism, where you brought him/her to a point of decision? (Each time you share the gospel with the same person count it) (Includes staff, student, faculty & volunteer evangelism and personal internet evangelism)',
            },
            personalEvangelismDecisions: {
                label: 'Personal Evangelism Decisions',
                tooltip:
                    'How many people have indicated a decision to receive Christ as their Savior and Lord after hearing a personal presentation of the gospel?',
            },
            holySpiritPresentations: {
                label: 'Holy Spirit Presentations',
                tooltip:
                    'How many people have heard a presentation of the ministry of the Holy Spirit and been given the opportunity to respond?',
            },
            groupEvangelism: {
                label: 'Group Evangelism',
                tooltip:
                    'What was the total number of people who heard the gospel and were brought to a point of decision through group evangelism?',
            },
            groupEvangelismDecisions: {
                label: 'Group Evangelism Decisions',
                tooltip:
                    'How many people have indicated a decision to receive Christ as their Savior and Lord after hearing a large group presentation of the gospel?',
            },
            mediaExposures: {
                label: 'Media Exposures',
                tooltip:
                    'How many people have been exposed to gospel content with an opportunity to respond through media exposures?',
            },
            mediaExposureDecisions: {
                label: 'Media Exposure Decisions',
                tooltip:
                    'How many people have indicated a decision to receive Christ as their Savior and Lord after being exposed to the gospel via media?',
            },
        },
        students: {
            title: 'Students',
            involved: {
                label: 'Involved',
                tooltip:
                    'How many students are regularly involved and attending movement events?',
            },
            engaged: {
                label: 'Engaged Disciples',
                tooltip:
                    'How many students have intentionally engaged a non believer in a spiritual conversation within the past semester? (The heart is that they have gone from merely attending movement events and begun to look outside of themselves to pass on their faith. Include all who are also leaders since to be a leader, one needs to be an engaged disciple.)',
            },
            leaders: {
                label: 'Leaders',
                tooltip:
                    'How many students are engaged disciples and are leading small groups of Win-Build-Send ministry? (Examples: groups focused on reaching target audiences, launching movements, etc. This number will be smaller than engaged disciples.)',
            },
        },
        faculty: {
            title: 'Faculty',
            involved: {
                label: 'Involved',
                tooltip: 'How many faculty are regularly involved? ',
            },
            engaged: {
                label: 'Engaged Disciples',
                tooltip:
                    'How many faculty have intentionally engaged in a spiritual conversation within the past semester? (The heart is that they have gone from merely attending movement events and begun to look outside of themselves to pass on their faith. Include all who are also leaders.)',
            },
            leaders: {
                label: 'Leaders',
                tooltip:
                    'How many faculty who are engaged disciples are leading Win-Build-Send activities? (Examples: groups focused on reaching target audiences, evangelistic Bible study, discipleship groups etc. This number will be smaller than engaged disciples.)',
            },
        },
        confirmModal: {
            description:
                'Ready to submit your movement indicators? If you want to change these numbers later you will need to go to Infobase to do so.',
        },
        successModal: {
            title: 'Movement Indicators Submitted!',
        },
        errorModal: {
            title: 'Something went wrong…',
            description:
                'There was an error connecting to Infobase. Please try again. If you receive this message multiple times, please contact support@missonhub.com.',
        },
    },
};
