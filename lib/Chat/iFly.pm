use strict;
use warnings;
package Chat::iFly;

use HTTP::Thin;
use HTTP::Request::Common;
use JSON;
use URI;
use Ouch;
use Moo;

has api_key => (
    is          => 'rw',
    required    => 1,
);



=head1 NAME

Wing::Client - A simple client to Wing's web services.

=head1 SYNOPSIS

 use Wing::Client;

 my $wing = Wing::Client->new(uri => 'https://www.thegamecrafter.com');

 my $game = $wing->get('game/528F18A2-F2C4-11E1-991D-40A48889CD00');
 
 my $session = $wing->post('session', { username => 'me', password => '123qwe', api_key_id => 'abcdefghijklmnopqrztuz' });

 $game = $wing->put('game/528F18A2-F2C4-11E1-991D-40A48889CD00', { session_id => $session->{id}, name => 'Lacuna Expanse' });

 my $status = $wing->delete('game/528F18A2-F2C4-11E1-991D-40A48889CD00', { session_id => $session->{id} });

=head1 DESCRIPTION

A light-weight wrapper for Wing's (L<https://github.com/plainblack/Wing>) RESTful API (an example of which can be found at: L<https://www.thegamecrafter.com/developer/>). This wrapper basically hides the request cycle from you so that you can get down to the business of using the API. It doesn't attempt to manage the data structures or objects the web service interfaces with.

=head1 METHODS

The following methods are available.

=head2 new ( params ) 

Constructor.

=over

=item params

A hash of parameters.

=over

=item uri

The base URI of the service you're interacting with. Defaults to C<https://api.iflychat.com>.

=back

=back

=cut

has uri => (
    is          => 'rw',
    default     => sub { 'https://api.iflychat.com' },
);

has port => (
    is          => 'rw',
    default     => sub { 443 },
);


=item agent

A HTTP::Thin object.

=back

=back

=cut

has agent => (
    is          => 'ro',
    required    => 0,
    lazy        => 1,
    builder     => '_build_agent',
);

sub _build_agent {
    return HTTP::Thin->new( )
}


has static_asset_base_uri => (
    is          => 'rw',
    required    => 1,
);

has ajax_uri => (
    is          => 'rw',
    required    => 1,
);

has enable_chatroom => (
    is          => 'rw',
    default     => sub { 1 },
    isa         => sub {
        ouch(442, 'enable_chatroom must be 1 or 2', 'enable_chatroom') unless ($_[0] ~~ [1,2]);
    }
);

has theme => (
    is          => 'rw',
    default     => sub { 'light' },
);

has notify_sound => (
    is          => 'rw',
    default     => sub { 1 },
    isa         => sub {
        ouch(442, 'notify_sound must be 1 or 2', 'notify_sound') unless ($_[0] ~~ [1,2]);
    }
);

has smileys => (
    is          => 'rw',
    default     => sub { 1 },
    isa         => sub {
        ouch(442, 'smileys must be 1 or 2', 'smileys') unless ($_[0] ~~ [1,2]);
    }
);

has log_chat => (
    is          => 'rw',
    default     => sub { 1 },
    isa         => sub {
        ouch(442, 'log_chat must be 1 or 2', 'log_chat') unless ($_[0] ~~ [1,2]);
    }
);

has chat_topbar_color => (
    is          => 'rw',
    default     => sub { '#222222' },
);

has chat_topbar_text_color => (
    is          => 'rw',
    default     => sub { '#FFFFFF' },
);

has font_color => (
    is          => 'rw',
    default     => sub { '#222222' },
);

has chat_list_header => (
    is          => 'rw',
    default     => sub { 'Chat' },
);

has public_chatroom_header => (
    is          => 'rw',
    default     => sub { 'Public Chatroom' },
);

has rel => (
    is          => 'rw',
    default     => sub { 0 },
);

has show_admin_list => (
    is          => 'rw',
    default     => sub { 1 },
    isa         => sub {
        ouch(442, 'show_admin_list must be 1 or 2', 'show_admin_list') unless ($_[0] ~~ [1,2]);
    }
);

has local_anonymous_names => (
    is          => 'rw',
    default     => sub { [qw(John Tim Tom Jason Fred Dave Mark James Don Ron Ed Sally Mary Sarah Kim Jim Nancy Wayne Bill Bob Karey Heather Victoria Becky Ana Larry Kayla Joe Tera Kevin Josh Chris Karen Maria Nadia Susan Mellisa Rebecca Bev Rachel Eddie Heidi Shana Shane Eric Erika)] },
    lazy        => 1,
);

has use_local_anonymous_names => (
    is          => 'rw',
    default     => sub { 1 },
);

has user_picture => (
    is          => 'rw',
    default     => sub { JSON::true },
);

has go_online_label => (
    is          => 'rw',
    default     => sub { 'Go Online' },
);

has go_idle_label => (
    is          => 'rw',
    default     => sub { 'Go Idle' },
);

has new_message_label => (
    is          => 'rw',
    default     => sub { 'New chat message!' },
);

has images_uri => (
    is          => 'rw',
    default     => sub { shift->static_asset_base_uri.'/themes/light/images/' },
    lazy        => 1,
);

has sound_player_uri => (
    is          => 'rw',
    default     => sub { shift->static_asset_base_uri.'/swf/sound.swf' },
    lazy        => 1,
);

has sound_file_uri => (
    is          => 'rw',
    default     => sub { shift->static_asset_base_uri.'/wav/notification.mp3' },
    lazy        => 1,
);

has no_users_html => (
    is          => 'rw',
    default     => sub { '<div class="item-list"><ul><li class="drupalchatnousers even first last">No users online</li></ul></div>' },
);

has smiley_uri => (
    is          => 'rw',
    default     => sub { shift->static_asset_base_uri.'/smileys/very_emotional_emoticons-png/png-32x32/' },
    lazy        => 1,
);

has use_stop_word_list => (
    is          => 'rw',
    default     => sub { 1 },
    isa         => sub {
        ouch(442, 'use_stop_word_list must be 1 or 2', 'use_stop_word_list') unless ($_[0] ~~ [1,2]);
    }
);

has stop_links => (
    is          => 'rw',
    default     => sub { 1 },
    isa         => sub {
        ouch(442, 'stop_links must be 1 or 2', 'stop_links') unless ($_[0] ~~ [1,2]);
    }
);

has allow_anonymous_links => (
    is          => 'rw',
    default     => sub { JSON::false },
);

has open_chatlist_default => (
    is          => 'rw',
    default     => sub { 1 },
    isa         => sub {
        ouch(442, 'open_chatlist_default must be 1 or 2', 'open_chatlist_default') unless ($_[0] ~~ [1,2]);
    }
);

has stop_words => (
    is          => 'rw',
    default     => sub { 'asshole,assholes,bastard,beastial,beastiality,beastility,bestial,bestiality,bitch,bitcher,bitchers,bitches,bitchin,bitching,blowjob,blowjobs,bullshit,clit,cock,cocks,cocksuck,cocksucked,cocksucker,cocksucking,cocksucks,cum,cummer,cumming,cums,cumshot,cunillingus,cunnilingus,cunt,cuntlick,cuntlicker,cuntlicking,cunts,cyberfuc,cyberfuck,cyberfucked,cyberfucker,cyberfuckers,cyberfucking,damn,dildo,dildos,dick,dink,dinks,ejaculate,ejaculated,ejaculates,ejaculating,ejaculatings,ejaculation,fag,fagging,faggot,faggs,fagot,fagots,fags,fart,farted,farting,fartings,farts,farty,felatio,fellatio,fingerfuck,fingerfucked,fingerfucker,fingerfuckers,fingerfucking,fingerfucks,fistfuck,fistfucked,fistfucker,fistfuckers,fistfucking,fistfuckings,fistfucks,fuck,fucked,fucker,fuckers,fuckin,fucking,fuckings,fuckme,fucks,fuk,fuks,gangbang,gangbanged,gangbangs,gaysex,goddamn,hardcoresex,horniest,horny,hotsex,jism,jiz,jizm,kock,kondum,kondums,kum,kumer,kummer,kumming,kums,kunilingus,lust,lusting,mothafuck,mothafucka,mothafuckas,mothafuckaz,mothafucked,mothafucker,mothafuckers,mothafuckin,mothafucking,mothafuckings,mothafucks,motherfuck,motherfucked,motherfucker,motherfuckers,motherfuckin,motherfucking,motherfuckings,motherfucks,niger,nigger,niggers,orgasim,orgasims,orgasm,orgasms,phonesex,phuk,phuked,phuking,phukked,phukking,phuks,phuq,pis,piss,pisser,pissed,pisser,pissers,pises,pisses,pisin,pissin,pising,pissing,pisof,pissoff,porn,porno,pornography,pornos,prick,pricks,pussies,pusies,pussy,pusy,pussys,pusys,slut,sluts,smut,spunk' },
);

has default_avatar_uri => (
    is          => 'rw',
    default     => sub { shift->static_asset_base_uri.'/themes/light/images/default_avatar.png' },
    lazy        => 1,
);

has default_room_uri => (
    is          => 'rw',
    default     => sub { shift->static_asset_base_uri.'/themes/light/images/default_room.png' },
    lazy        => 1,
);


sub render_html {
    my ($self) = @_;
    my $out = '<script type="text/javascript">Drupal={};Drupal.settings={};Drupal.settings.drupalchat={};Drupal.settings='.to_json($self->init()).';</script>';
    $out .= '<script type="text/javascript" src="' . $self->static_asset_base_uri .  '/js/ba-emotify.js"></script>';
    $out .= '<script type="text/javascript" src="' . $self->static_asset_base_uri .  '/js/jquery.titlealert.min.js"></script>';
    $out .= '<script type="text/javascript" src="' . $self->static_asset_base_uri .  '/js/iflychat.js"></script>';
    return $out;
}


sub render_ajax {
    my ($self, $user) = @_;
}

sub init {
    my $self = shift;
    my %settings = (
        uid                     => '',
        username                => '',
        current_timestamp       => time(),
        polling_method          => 3,
        pollUrl                 => ' ',
        sendUrl                 => ' ',
        statusUrl               => ' ',
        status                  => 1,
        goOnline                => $self->go_online_label,
        goIdle                  => $self->go_idle_label,
        newMessage              => $self->new_message_label,
        images                  => $self->images_uri,
        sound                   => $self->sound_player_uri,
        soundFile               => $self->sound_file_uri,
        noUsers                 => $self->no_users_html,
        smileyURL               => $self->smiley_uri,
        addUrl                  => ' ',
        notificationSound       => 1,
        basePath                => '/',
        useStopWordList         => $self->use_stop_word_list,
        blockHL                 => $self->stop_links,
        allowAnonHL             => $self->allow_anonymous_links,
        iup                     => $self->user_picture,
        admin                   => 0,
        session_key             => '',
        exurl                   => $self->ajax_uri,
        open_chatlist_default   => $self->open_chatlist_default,
        external_host           => $self->uri,
        external_port           => $self->port,
        external_a_host         => $self->uri,
        extrenal_a_port         => $self->port,
        upl                     => '#',
    );
    
    if ($self->use_stop_word_list == 2) {
        $settings{stopWordList} = $self->stop_words;
    }

    if ($self->user_picture) {
        $settings{up} = $self->default_avatar_uri;
        $settings{default_up} = $self->default_avatar_uri;
        $settings{default_cr} = $self->default_room_uri;
    }
    
    return { drupalchat => \%settings };
}



sub generate_anonymous_user {
    my $self = shift;
    my %user = ( id => '0-'.time() );
    if ($self->use_local_anonymous_names) {
        my $names = $self->local_anonymous_names;
        $user{name} = 'Guest '.$names->[rand @{$names}];
    }
    else {
        $user{name} = 'Guest '.$self->fetch_anonymous_name;
    }
    return \%user;
}

sub fetch_anonymous_name {
    my $self = shift;
    my $response = $self->agent->request(GET $self->_create_uri('/anam/v/usa'));
    if ($response->is_success) {
        return $response->decoded_content;
    }
}


=head2 get_key( user )

This method is used to essentially log a user into the chat system. It generates a key that is used by the javascript to communicate back to the chat server.

=over

=item user

A hash reference containing the definition of a user. If this is an anonymous user then generate it using C<generate_anonymous_user>.

=over

=item id

The unique id of the user. It can be any string, but cannot contain hyphens (C<->). If your IDs contain hypens iFly recommends replacing them with underscores (C<_>).

=item name

The name or username of the user.

=item is_admin

Defaults to 0. Can be set to 1 if the user should have chat admin privileges.

=item custom_roles

Defaults to C<normal>. Ignored entirely if C<is_admin> is set to 1. You can also pass in a hash of custom roles (not admin or normal) that will be used as CSS classes for styling. For example:

 {
    1   => 'cool',
    2   => 'slick',
 }

=item avatar_uri

A URI string that references a picture used to identify the user.

=item profile_uri

A URI string that will link other users to this user's profile on the web site.

=item relationships_set

This allows you to set up buddy lists within the chat. It is a hash reference taking the form of:

 {
    1   => {
        name        => 'friend',
        plural      => 'friends',
        valid_uids  =>  ['user_id_1', 'user_id_5', 'user_id_3']
    },
    2   => {
        name        => 'co-worker',
        plural      => 'co-workers',
        valid_uids  =>  ['user_id_3', 'user_id_4', 'user_id_2']
    },
 }


=back

=back 

=cut

sub get_key {
    my ($self, $user) = @_;
    my $result = $self->post('/p/', {
        api_key         => $self->api_key,
        uname           => $user->{name},
        uid             => $user->{id},
        image_path      => $self->static_asset_base_uri.'/themes/light/images',
        isLog           => JSON::true,
        whichTheme      => 'blue',
        enableStatus    => JSON::true,
        role            => $user->{is_admin} ? 'admin' : ((exists $user->{custom_roles}) ? $user->{custom_roles} : 'normal'),
        validState      => ['available','offline','busy','idle'],
        up              => (exists $user->{avatar_uri}) ? $user->{avatar_uri} : $self->static_asset_base_uri.'/themes/light/images/default_avatar.png',
        upl             => (exists $user->{profile_uri}) ? $user->{profile_uri} : '#',
        rel             => (exists $user->{relationships_set}) ? 1 : 0,
        valid_uids      => $user->{relationships_set},
    });
    $result->{uid} = $user->{id};
    $result->{name} = $user->{name};
    return $result;
}

sub update_settings {
    my ($self) = @_;
    return $self->post('/z/', {
        api_key                     => $self->api_key,
        enable_chatroom             => $self->enable_chatroom,
        theme                       => $self->theme,
        notify_sound                => $self->notify_sound,
        smileys                     => $self->smileys,
        log_chat                    => $self->log_chat,
        chat_topbar_color           => $self->chat_topbar_color,
        chat_topbar_text_color      => $self->chat_topbar_text_color,
        font_color                  => $self->font_color,
        chat_list_header            => $self->chat_list_header,
        public_chatroom_header      => $self->public_chatroom_header,
        rel                         => $self->rel,
        version                     => 'perl',
        show_admin_list             => $self->show_admin_list,        
    });
}


sub get_message_thread {
    my ($self, $uid1, $uid2) = @_;
    $uid1 ||= 1;
    $uid2 ||= 2;
    return $self->post('/q/', { api_key => $self->api_key, uid1 => $uid1, uid2 => $uid2} );
}

sub get_message_inbox {
    my ($self, $uid1) = @_;
    $uid1 ||= 1;
    return $self->post('/r/', { api_key => $self->api_key, uid1 => $uid1} );
}



















=head2 get(path, params)

Performs a C<GET> request, which is used for reading data from the service.

=over

=item path

The path to the REST interface you wish to call. You can abbreviate and leave off the C</api/> part if you wish.

=item params

A hash reference of parameters you wish to pass to the web service.

=back

=cut

sub get {
    my ($self, $path, $params) = @_;
    my $uri = $self->_create_uri($path);
    $uri->query_form($params);
    return $self->_process_request( GET $uri );
}

=head2 delete(path, params)

Performs a C<DELETE> request, deleting data from the service.

=over

=item path

The path to the REST interface you wish to call. You can abbreviate and leave off the C</api/> part if you wish.

=item params

A hash reference of parameters you wish to pass to the web service.

=back

=cut

sub delete {
    my ($self, $path, $params) = @_;
    my $uri = $self->_create_uri($path);
    return $self->_process_request(POST $uri->as_string, $params, 'X-HTTP-Method' => 'DELETE', Content_Type => 'form-data', Content => $params );
}

=head2 put(path, params)

Performs a C<PUT> request, which is used for updating data in the service.

=over

=item path

The path to the REST interface you wish to call. You can abbreviate and leave off the C</api/> part if you wish.

=item params

A hash reference of parameters you wish to pass to the web service.

=back

=cut

sub put {
    my ($self, $path, $params) = @_;
    my $uri = $self->_create_uri($path);
    return $self->_process_request( POST $uri->as_string, 'X-HTTP-Method' => 'PUT', Content_Type => 'form-data', Content => $params,);
}

=head2 post(path, params)

Performs a C<POST> request, which is used for creating data in the service.

=over

=item path

The path to the REST interface you wish to call. You can abbreviate and leave off the C</api/> part if you wish.

=item params

A hash reference of parameters you wish to pass to the web service.

=back

=cut

sub post {
    my ($self, $path, $params) = @_;
    my $uri = $self->_create_uri($path);
    return $self->_process_request( POST $uri->as_string, Content_Type => 'application/json', Content => to_json($params) );
}

sub _create_uri {
    my $self = shift;
    my $path = shift;
    return URI->new($self->uri.$path);
}

sub _process_request {
    my $self = shift;
    $self->_process_response($self->agent->request( @_ ));
}

sub _process_response {
    my $self = shift;
    my $response = shift;
    if ($response->is_success) {
        my $result = eval { from_json($response->decoded_content) }; 
        if ($@) {
            ouch 500, 'Server returned unparsable content.', { error => $@, content => $response->decoded_content };
        }
        else {
            return $result;
        }
    }
    else {
        warn $response->decoded_content;
        ouch $response->code, $response->message, $response->decoded_content;
    }
}

=head1 PREREQS

L<HTTP::Thin>
L<Ouch>
L<HTTP::Request::Common>
L<JSON>
L<URI>
L<Moo>

=head1 SUPPORT

=over

=item Repository

L<http://github.com/rizen/Chat-iFly>

=item Bug Reports

L<http://github.com/rizen/Chat-iFly/issues>

=back

=head1 AUTHOR

JT Smith <jt_at_plainblack_dot_com>

=head1 LEGAL

This module is Copyright 2014 Plain Black Corporation. It is distributed under the same terms as Perl itself. 

=cut


1;
