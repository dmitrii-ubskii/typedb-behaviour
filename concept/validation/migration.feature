#
# Copyright (C) 2022 Vaticle
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#

#noinspection CucumberUndefinedStep
Feature: Schema migration

  Background:
    Given typedb starts
    Given connection opens with default authentication
    Given connection has been opened
    Given connection does not have any database
    Given connection create database: typedb
    Given connection open schema session for database: typedb
    Given session opens transaction of type: write


  Scenario: An ownership can be moved down one type, with data in place at the lower levels
    Given put attribute type: attr0, with value type: string
    Given put entity type: ent0
    Given entity(ent0) set owns attribute type: attr0, with annotations: key
    Given put entity type: ent1
    Given entity(ent1) set supertype: ent0
    Given transaction commits

    Given connection close all sessions
    Given connection open data session for database: typedb
    Given session opens transaction of type: write
    Given $ent1 = entity(ent1) create new instance
    Given $attr0 = attribute(attr0) as(string) put: "attr0"
    Given entity $ent1 set has: $attr0
    Given transaction commits

    Given connection close all sessions
    Given connection open schema session for database: typedb

    # Should break
    When session opens transaction of type: write
    Then entity(ent1) set owns attribute type: attr0, with annotations: unique; throws exception

    When session opens transaction of type: write
    Then entity(ent0) unset owns attribute type: attr0; throws exception

    When session opens transaction of type: write
    When entity(ent1) set owns attribute type: attr0, with annotations: key
    # Can't commit yet, because of the redundant declarations
    Then transaction commits; throws exception

    When session opens transaction of type: write
    When entity(ent1) set owns attribute type: attr0, with annotations: key
    When entity(ent0) unset owns attribute type: attr0
    Then transaction commits


  Scenario: An ownership can be moved up one type, with data in place
    Given put attribute type: attr0, with value type: string
    Given put entity type: ent0
    Given put entity type: ent1
    Given entity(ent1) set supertype: ent0
    Given entity(ent1) set owns attribute type: attr0, with annotations: key
    Given transaction commits

    Given connection close all sessions
    Given connection open data session for database: typedb
    Given session opens transaction of type: write
    Given $ent1 = entity(ent1) create new instance
    Given $attr0 = attribute(attr0) as(string) put: "attr0"
    Given entity $ent1 set has: $attr0
    Given transaction commits

    Given connection close all sessions
    Given connection open schema session for database: typedb

    When session opens transaction of type: write
    When entity(ent0) set owns attribute type: attr0, with annotations: key
    # Can't commit yet, because of the redundant declarations
    Then transaction commits; throws exception

    When session opens transaction of type: write
    When entity(ent0) set owns attribute type: attr0, with annotations: key
    When entity(ent1) unset owns attribute type: attr0
    Then transaction commits


  Scenario: A played role can be moved down one type, with data in place at the lower levels
    Given put relation type: rel0
    Given relation(rel0) set relates role: role0
    Given put entity type: ent0
    Given entity(ent0) set plays role: rel0:role0
    Given put entity type: ent1
    Given entity(ent1) set supertype: ent0
    Given transaction commits

    Given connection close all sessions
    Given connection open data session for database: typedb
    Given session opens transaction of type: write
    Given $ent1 = entity(ent1) create new instance
    Given $rel0 = relation(rel0) create new instance
    Given relation $rel0 add player for role(role0): $ent1
    Given transaction commits

    Given connection close all sessions
    Given connection open schema session for database: typedb

    When session opens transaction of type: write
    Then entity(ent0) unset plays role: rel0:role0; throws exception

    When session opens transaction of type: write
    Then entity(ent1) set plays role: rel0:role0
    Then entity(ent0) unset plays role: rel0:role0
    Then transaction commits


  Scenario: A played role can be moved up one type, with data in place
    Given put relation type: rel0
    Given relation(rel0) set relates role: role0
    Given put entity type: ent0
    Given put entity type: ent1
    Given entity(ent1) set supertype: ent0
    Given entity(ent1) set plays role: rel0:role0
    Given transaction commits

    Given connection close all sessions
    Given connection open data session for database: typedb
    Given session opens transaction of type: write
    Given $ent1 = entity(ent1) create new instance
    Given $rel0 = relation(rel0) create new instance
    Given relation $rel0 add player for role(role0): $ent1
    Given transaction commits

    Given connection close all sessions
    Given connection open schema session for database: typedb

    When session opens transaction of type: write
    Then entity(ent0) set plays role: rel0:role0
    Then entity(ent1) unset plays role: rel0:role0
    Then transaction commits


  Scenario: A type moved with ownership instances in-place by re-declaring ownerships
    Given put attribute type: attr0, with value type: string
    Given put entity type: ent0
    Given entity(ent0) set owns attribute type: attr0, with annotations: key
    Given put entity type: ent1
    Given entity(ent1) set supertype: ent0
    Given transaction commits

    Given connection close all sessions
    Given connection open data session for database: typedb
    Given session opens transaction of type: write
    Given $ent1 = entity(ent1) create new instance
    Given $attr0 = attribute(attr0) as(string) put: "attr0"
    Given entity $ent1 set has: $attr0
    Given transaction commits

    Given connection close all sessions
    Given connection open schema session for database: typedb

    # Should break
    When session opens transaction of type: write
    Then entity(ent1) set supertype: entity; throws exception
    Given session transaction close

    When session opens transaction of type: write
    Then entity(ent1) set owns attribute type: attr0, with annotations: key
    Then entity(ent1) set supertype: entity
    Then transaction commits


  Scenario: A type moved with plays instances in-place by re-declaring played roles
    Given put relation type: rel0
    Given relation(rel0) set relates role: role0
    Given put entity type: ent0
    Given entity(ent0) set plays role: rel0:role0
    Given put entity type: ent1
    Given entity(ent1) set supertype: ent0
    Given transaction commits

    Given connection close all sessions
    Given connection open data session for database: typedb
    Given session opens transaction of type: write
    Given $ent1 = entity(ent1) create new instance
    Given $rel0 = relation(rel0) create new instance
    Given relation $rel0 add player for role(role0): $ent1
    Given transaction commits

    Given connection close all sessions
    Given connection open schema session for database: typedb

    When session opens transaction of type: write
    Then entity(ent1) set supertype: entity; throws exception

    When session opens transaction of type: write
    Then entity(ent1) set plays role: rel0:role0
    Then entity(ent1) set supertype: entity
    Then transaction commits

  Scenario: A type can be inserted into an existing hierarchy which has data in place
    Given put relation type: rel
    Given relation(rel) set relates role: role0
    Given put attribute type: attr, with value type: string
    Given put entity type: ent0
    Given entity(ent0) set plays role: rel:role0
    Given entity(ent0) set owns attribute type: attr, with annotations: key
    Given put entity type: ent1
    Given entity(ent1) set supertype: ent0
    Given transaction commits

    Given connection close all sessions
    Given connection open data session for database: typedb
    Given session opens transaction of type: write
    Given $ent1 = entity(ent1) create new instance with key(attr): "ent1"
    Given $rel = relation(rel) create new instance
    Given relation $rel add player for role(role0): $ent1
    Given transaction commits

    Given connection close all sessions
    Given connection open schema session for database: typedb
    When session opens transaction of type: write
    Then put entity type: ent05
    Then entity(ent05) set supertype: ent0
    Then entity(ent1) set supertype: ent05
    Then transaction commits


  Scenario: A type can be removed from an existing hierarchy which has data in place
    Given put relation type: rel
    Given relation(rel) set relates role: role0
    Given put attribute type: attr, with value type: string
    Given put entity type: ent0
    Given entity(ent0) set plays role: rel:role0
    Given entity(ent0) set owns attribute type: attr, with annotations: key
    Given put entity type: ent05
    Given entity(ent05) set supertype: ent0
    Given put entity type: ent1
    Given entity(ent1) set supertype: ent05
    Given transaction commits

    Given connection close all sessions
    Given connection open data session for database: typedb
    Given session opens transaction of type: write
    Given $ent1 = entity(ent1) create new instance with key(attr): "ent1"
    Given $rel = relation(rel) create new instance
    Given relation $rel add player for role(role0): $ent1
    Given transaction commits

    Given connection close all sessions
    Given connection open schema session for database: typedb
    When session opens transaction of type: write
    Then entity(ent1) set supertype: ent0
    Then delete entity type: ent05
    Then transaction commits


  Scenario: Attribute types can be split in two, with instances and ownerships migrated to subtypes
    Given typeql define
    """
    define
      name sub attribute, value string;
      being sub entity, abstract, owns name @key;
      person sub being;
      dog sub being;
    """
    Given transaction commits
    Given connection close all sessions
    Given connection open data session for database: typedb
    Given session opens transaction of type: write
    Given typeql insert
    """
    insert
    $john isa person, has name "john";
    $scooby isa dog, has name "scooby";
    """
    Given transaction commits
    Given connection close all sessions

    When connection open schema session for database: typedb
    When session opens transaction of type: write
    When put attribute type: dog-name, with value type: string
    When put attribute type: person-name, with value type: string
    When entity(person) set owns attribute type: person-name
    When entity(dog) set owns attribute type: dog-name
    Then transaction commits
    When connection close all sessions
    When connection open data session for database: typedb
    When session opens transaction of type: write
    When typeql insert
    """
    match $p isa person, has name $name; ?value = $name;
    insert $p has person-name ?value;
    """
    When typeql insert
    """
    match $d isa dog, has name $name; ?value = $name;
    insert $d has dog-name ?value;
    """
    Then transaction commits
    Then connection close all sessions
    When connection open schema session for database: typedb
    When session opens transaction of type: write
    # adjust annotations
    When entity(person) set owns attribute type: person-name, with annotations: key
    When entity(dog) set owns attribute type: dog-name, with annotations: key
    When entity(being) set owns attribute type: name
    Then transaction commits
    Then connection close all sessions

    When connection open data session for database: typedb
    When session opens transaction of type: write
    When typeql delete
    """
    match $n isa! name;
    delete $n isa name;
    """
    Then transaction commits
    Then connection close all sessions

    When connection open schema session for database: typedb
    When session opens transaction of type: write
    When attribute(name) set abstract: true
    When attribute(person-name) set supertype: name
    When attribute(dog-name) set supertype: name
    When entity(person) set owns attribute type: person-name as name, with annotations: key
    When entity(dog) set owns attribute type: dog-name as name
    Then transaction commits


  Scenario: Owner types can be split in two, with instances and ownerships migrated to subtypes
    Given typeql define
    """
    define
    male-specific sub attribute, value string;
    female-specific sub attribute, value string;
    gender sub attribute, value string;
    common sub attribute, value string;
    person sub entity, owns gender, owns common, owns male-specific, owns female-specific;
    """
    Given transaction commits
    Given connection close all sessions
    Given connection open data session for database: typedb
    Given session opens transaction of type: write
    Given typeql insert
    """
    insert
      $alice isa person, has gender "F", has common "c-alice", has female-specific "f-alice";
      $bob isa person, has gender "M", has common "c-bob", has male-specific "m-bob";
    """
    Given transaction commits
    Given connection close all sessions

    When connection open schema session for database: typedb
    When session opens transaction of type: write
    When typeql define
    """
    define
    male sub person;
    female sub person;
    """
    Then transaction commits
    Then connection close all sessions

    When connection open data session for database: typedb
    When session opens transaction of type: write
    When typeql insert
    """
    match $p isa person, has gender "M", has male-specific $ms, has common $c;
    insert $m isa male, has $ms, has $c;
    """
    When typeql insert
    """
    match $p isa person, has gender "F", has female-specific $fs, has common $c;
    insert $f isa female, has $fs, has $c;
    """
    When typeql delete
    """
    match $p isa! person;
    delete $p isa person;
    """
    When typeql delete
    """
    match $g isa! gender;
    delete $g isa gender;
    """
    Then transaction commits
    Then connection close all sessions

    When connection open schema session for database: typedb
    When session opens transaction of type: write
    When entity(male) set owns attribute type: male-specific
    When entity(female) set owns attribute type: female-specific
    When entity(person) unset owns attribute type: male-specific
    When entity(person) unset owns attribute type: female-specific
    When entity(person) set abstract: true
    When delete attribute type: gender
    Then transaction commits
