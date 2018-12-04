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
        beta: {
            welcome: {
                accept: "Let's Go!",
                no_thanks: 'No Thanks',
                p1:
                    'We are excited about the improved navigation and performance. We hope you enjoy it, too!',
                p2:
                    'If you need any help, click the life ring in the bottom right!',
                title: 'Welcome to the new MissionHub!',
                try: 'Try Beta',
            },
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
            snooze_for_24_hours: 'Snooze reminder for 24 hours',
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
                    merge_people: 'Error occurred while merging people',
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
            },
            retry_instructions: 'Click to retry',
        },
        followup_status: {
            attempted_contact: 'Attempted Contact',
            completed: 'Completed',
            contacted: 'Contacted',
            do_not_contact: 'Do Not Contact',
            uncontacted: 'Uncontacted',
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
        leader: 'Leader',
        mass_edit: {
            save: 'Edit {{contactCount}} contacts',
            title: 'Edit Contacts',
            unchanged: 'Unchanged',
        },
        member: 'Member',
        merge_winner: {
            merge: 'Merge',
            subtitle:
                'Choose the winner of the merge. The other people will be merged into the winner.',
            title: 'Merge Winner',
            person_fields: {
                first_name: 'First name',
                last_name: 'Last name',
                gender: 'Gender',
                email_addresses: 'Email addresses',
                phone_numbers: 'Phone numbers',
                created_date: 'Person created',
                updated_date: 'Person updated',
            },
            user_fields: {
                id: 'User id',
                username: 'Username',
                created_date: 'User created',
                updated_date: 'User updated',
                login_date: 'Last login',
            },
        },
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
                merge_disabled_hover:
                    'Select between 2 and 4 contacts to merge them',
                merge_hover: 'Merge the selected contacts',
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
            },
            roots: 'Ministries',
            suborgs: {
                header: 'Ministries',
            },
            surveyResponses: {
                header: 'Survey Responses',
            },
            surveys: {
                header: 'Surveys',
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
            goal: 'Goal Tracker',
            groups: 'Groups',
            logout: 'Sign Out',
            manage: 'Manage Ministries',
            my_profile: 'My Profile',
            powered_by_cru: 'Powered by Cru',
            report_movement_indicators: 'Report Movement Indicators',
            search: {
                in: 'in',
            },
            preferences: 'Preferences',
            snapshot: 'Snapshot View',
            support: 'Support',
            terms: 'Terms of Service',
            trend: 'Trend Tracker',
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
                apply_groups: 'Assign {{name}} to the following groups.',
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
    surveys: {
        preview: 'Preview this survey',
        publicView: {
            preview: {
                header: 'This is a preview.',
                inactive: 'The survey you are viewing is inactive.',
                description:
                    'While in preview mode, you cannot submit survey responses.',
            },
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
        legacyNav: 'Revert to legacy navigation',
    },
    peopleScreen: {
        filterSearchPlaceholder: 'Search answers',
        answerMatchingOptions: {
            exactly: 'Exactly',
            contains: 'Contains',
            doesNotContain: 'Does not contain',
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
