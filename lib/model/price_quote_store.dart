import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

import 'price_quote_model.dart';

const _avatarsLocation = 'reply/avatars';

class EmailStore with ChangeNotifier {
  EmailStore() {}

  static final _inbox = <Email>[
    /*
    InboxEmail(
      id: '1',
      tglBuat: Timestamp.fromDate(DateTime.parse('05/05/2023')),
      time: '',
      subject: 'Klien A',
      message: 'Barang A 30 Pcs',
      avatar: '$_avatarsLocation/avatar_express.png',
      recipients: 'Jeff',
      containsPictures: false,
    ),
    InboxEmail(
      id: '2',
      tglBuat: Timestamp.fromDate(DateTime.parse('06/05/2023')),
      time: '',
      subject: 'Klien A',
      message: 'Barang B 15 Pcs\n\n'
          'Barang C 10 Pcs',
      avatar: '$_avatarsLocation/avatar_5.jpg',
      recipients: 'Jeff',
      containsPictures: false,
    ),
    InboxEmail(
      id: '3',
      tglBuat: Timestamp.fromDate(DateTime.parse('06/05/2023')),
      time: '',
      subject: 'Klien B',
      message: 'Barang A 5 Pcs',
      avatar: '$_avatarsLocation/avatar_3.jpg',
      recipients: 'Jeff',
      containsPictures: false,
    ),
    InboxEmail(
      id: '4',
      tglBuat: Timestamp.fromDate(DateTime.parse('07/05/2023')),
      time: '',
      subject: 'Klien C',
      message: 'Barang A 12 Pcs\n\n'
          'Barang C 3 Pcs\n\n'
          'Ali',
      avatar: '$_avatarsLocation/avatar_8.jpg',
      recipients: 'Allison, Kim, Jeff',
      containsPictures: false,
    ),
    InboxEmail(
      id: '5',
      tglBuat: Timestamp.fromDate(DateTime.parse('08/05/2023')),
      time: '',
      subject: 'Klien D',
      message: 'Barang A 11 Pcs\n\n'
          'Barang D 25 Pcs\n\n'
          'Ali',
      avatar: '$_avatarsLocation/avatar_4.jpg',
      recipients: 'Jeff',
      containsPictures: false,
    ),*/
  ];

  static final _outbox = <Email>[
    /*
    Email(
      id: '10',
      tglBuat: Timestamp.fromDate(DateTime.parse('08/05/2023')),
      time: '4 hrs ago',
      subject: 'High school reunion?',
      message:
          'Hi friends,\n\nI was at the grocery store on Sunday night.. when I ran into Genie Williams! I almost didn\'t recognize her afer 20 years!\n\n'
          'Anyway, it turns out she is on the organizing committee for the high school reunion this fall. I don\'t know if you were planning on going or not, but she could definitely use our help in trying to track down lots of missing alums. '
          'If you can make it, we\'re doing a little phone-tree party at her place next Saturday, hoping that if we can find one person, thee more will...',
      avatar: '$_avatarsLocation/avatar_7.jpg',
      recipients: 'Jeff',
      containsPictures: false,
    ),
    Email(
      id: '11',
      tglBuat: Timestamp.fromDate(DateTime.parse('08/05/2023')),
      time: '7 hrs ago',
      subject: 'Recipe to try',
      message:
          'Raspberry Pie: We should make this pie recipe tonight! The filling is '
          'very quick to put together.',
      avatar: '$_avatarsLocation/avatar_2.jpg',
      recipients: 'Jeff',
      containsPictures: false,
    ),
  */
  ];

  static final _drafts = <Email>[
    /*
    Email(
      id: '12',
      tglBuat: Timestamp.fromDate(DateTime.parse('08/05/2023')),
      time: '2 hrs ago',
      subject: '(No subject)',
      message: 'Hey,\n\n'
          'Wanted to email and see what you thought of',
      avatar: '$_avatarsLocation/avatar_2.jpg',
      recipients: 'Jeff',
      containsPictures: false,
    ),*/
  ];

  List<Email> get _allEmails => [
        ..._inbox,
        ..._outbox,
        ..._drafts,
      ];

  List<Email> get inboxEmails {
    return _inbox.where((email) {
      if (email is InboxEmail) {
        return email.inboxType == InboxType.normal &&
            !trashEmailIds.contains(email.id);
      }
      return false;
    }).toList();
  }

  List<Email> get spamEmails {
    return _inbox.where((email) {
      if (email is InboxEmail) {
        return email.inboxType == InboxType.spam &&
            !trashEmailIds.contains(email.id);
      }
      return false;
    }).toList();
  }

  Email get currentEmail =>
      _allEmails.firstWhere((email) => email.id == _selectedEmailId);

  List<Email> get outboxEmails =>
      _outbox.where((email) => !trashEmailIds.contains(email.id)).toList();

  List<Email> get draftEmails =>
      _drafts.where((email) => !trashEmailIds.contains(email.id)).toList();

  Set<String> starredEmailIds = {};

  bool isEmailStarred(String id) =>
      _allEmails.any((email) => email.id == id && starredEmailIds.contains(id));

  bool get isCurrentEmailStarred => starredEmailIds.contains(currentEmail.id);

  List<Email> get starredEmails {
    return _allEmails
        .where((email) => starredEmailIds.contains(email.id))
        .toList();
  }

  void starEmail(String id) {
    starredEmailIds.add(id);
    notifyListeners();
  }

  void unstarEmail(String id) {
    starredEmailIds.remove(id);
    notifyListeners();
  }

  Set<String> trashEmailIds = {'7', '8'};

  List<Email> get trashEmails {
    return _allEmails
        .where((email) => trashEmailIds.contains(email.id))
        .toList();
  }

  void deleteEmail(String id) {
    trashEmailIds.add(id);
    notifyListeners();
  }

  int _selectedEmailId = -1;

  int get selectedEmailId => _selectedEmailId;

  set selectedEmailId(int value) {
    _selectedEmailId = value;
    notifyListeners();
  }

  bool get onMailView => _selectedEmailId > -1;

  MailboxPageType _selectedMailboxPage = MailboxPageType.inbox;

  MailboxPageType get selectedMailboxPage => _selectedMailboxPage;

  set selectedMailboxPage(MailboxPageType mailboxPage) {
    _selectedMailboxPage = mailboxPage;
    notifyListeners();
  }

  bool _onSearchPage = false;

  bool get onSearchPage => _onSearchPage;

  set onSearchPage(bool value) {
    _onSearchPage = value;
    notifyListeners();
  }
}
