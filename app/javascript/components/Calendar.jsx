import React  from 'react'
import Calendar from 'react-calendar';
import Routes from '../packs/routes.js.erb';
import Select from 'react-select';
import moment from "moment-timezone";

class BookingsCalendar extends React.Component {

  constructor() {
    super();
    this.state = {
      calendarDates: null,
      selectedData: [],
      clientFilter: null,
      locationFilter: null,
      resourceFilter: null,
      timeZone: moment.tz.guess()
    }
  }

  timeZoneData = moment.tz.names().map((name) => {
    return {value: name, label: name}
  })

  componentDidMount() {
    this.setSelectedData()
  }

  getSelectedDateIds = () => {
    let all_ids = [];
    if (this.state.calendarDates !== null) {
      let startDate = moment(this.state.calendarDates[0]);
      const endDate = moment(this.state.calendarDates[1] || startDate);
      while (startDate <= endDate) {
        const ids = this.props.time_groups[startDate.format(this.props.date_format)];
        if (!!ids) { all_ids.push(...ids) }
        startDate = startDate.add(1, 'days')
      }
    }
    return all_ids
  }

  setSelectedData = () => {
    const all_ids = this.getSelectedDateIds()
    const filters = [this.state.clientFilter,
                     this.state.locationFilter,
                     this.state.resourceFilter].filter(obj => obj !== null);
    const ids = filters.length ? all_ids.filter(id => filters.every(f => f[id])) : all_ids
    this.setState({selectedData: ids.map(id => this.props.data[id])});
  };

  render() {
    return (
      <div className={'calendar-container'}>
        <div className={'calendar-all-filters-container'}>
          <div className={'calendar-filter-container'}>
            <CalendarFilter
              label={this.props.client_label}
              groups={this.props.client_groups}
              onFilterChange={(obj) => this.setState({clientFilter: obj}, this.setSelectedData)}
              allLabel={this.props.filter_options.all}
              nullLabel={this.props.filter_options.null}
            />
            <CalendarFilter
              label={this.props.location_label}
              groups={this.props.location_groups}
              onFilterChange={(obj) => this.setState({locationFilter: obj}, this.setSelectedData)}
              allLabel={this.props.filter_options.all}
            />
            <CalendarFilter
              label={this.props.resource_label}
              groups={this.props.resource_groups}
              onFilterChange={(obj) => this.setState({resourceFilter: obj}, this.setSelectedData)}
              allLabel={this.props.filter_options.all}
            />
          </div>
          <div className={'calendar-calendar-container'}>
            <Calendar
              view={'month'}
              selectRange={true}
              minDate={moment(this.props.min_date).toDate()}
              maxDate={moment(this.props.max_date).toDate()}
              onChange={(dates) => this.setState({calendarDates: dates}, this.setSelectedData)}
            />
          </div>
          <div>
            <label>
              <span className={'calendar-select-label'}>{'Time zone'}</span>
              <Select
                isSearchable={true}
                closeMenuOnSelect={true}
                defaultValue={{value: this.state.timeZone, label: this.state.timeZone}}
                onChange={(val) => this.setState({timeZone: val.value})}
                options={this.timeZoneData}
              />
            </label>
          </div>
        </div>
        <div className={'calendar-booking-container'}>
          <BookingPanel
            data={this.state.selectedData}
            user_id={this.props.user_id}
            show_buttons={this.props.show_booking_button}
            delete_availabilities={this.props.delete_availabilities}
            timeZone={this.state.timeZone}
          />
        </div>
      </div>
    )
  }
}

class CalendarFilter extends React.Component {

  constructor() {
    super();
    this.state = {
      all_selected: true
    }
  }

  sortFunt = (a, b) => {
    return (a.label > b.label) ? 1 : -1
  }

  getOptions = () => {
    const options = Object.keys(this.props.groups).map((key) => {
      if (key) {
        return {value: key, label: key}
      } else {
        return {value: key, label: this.props.nullLabel}
      }
    })
    if (this.props.allLabel) {
      options.push({value: true, label: this.props.allLabel})
    }
    return options.sort(this.sortFunt)
  }

  getFilterData = (newVal) => {
    if (newVal === null) {
      this.props.onFilterChange({})
      this.setState({all_selected: false})
    } else if (newVal.some(({value}) => value === true)) {
      this.props.onFilterChange(null)
      this.setState({all_selected: true})
    } else {
      const objs = newVal.map(({value}) => Object.fromEntries(this.props.groups[value].map(k => [k, true])))
      this.props.onFilterChange(Object.assign({}, ...objs))
      this.setState({all_selected: false})
    }
  }

  render() {
    const options = this.getOptions()
    if (Object.keys(this.props.groups).filter(Boolean).length < 2) {
      return ''
    } else {
      return (
        <label>
          <span className={'calendar-select-label'}>{this.props.label}</span>
          <Select
            isClearable={true}
            isSearchable={true}
            closeMenuOnSelect={false}
            defaultValue={{value: true, label: this.props.allLabel}}
            isMulti
            onChange={this.getFilterData}
            options={options}
            isOptionDisabled={() => this.state.all_selected}
          />
        </label>
      )
    }
  }
}

class BookingPanel extends React.Component {

  columns = [
    {
      Header: 'Resource Name',
      accessor: 'resource_name',
      Cell: (row) => { return <a href={Routes.resource_path(row.resource_id)}>{row.resource_name}</a> }
    },
    {
      Header: 'Resource Type',
      accessor: 'resource_type'
    },
    {
      Header: 'Location',
      Cell: (row) => { return <a href={Routes.location_path(row.location_id)}>{row.location_name}</a> }
    },
    {
      Header: 'Start Time',
      Cell: (row) => { return moment(row.start_time).tz(this.props.timeZone).format('MMMM Do YYYY, h:mm:ss a z') },
    },
    {
      Header: 'End Time',
      Cell: (row) => { return moment(row.end_time).tz(this.props.timeZone).format('MMMM Do YYYY, h:mm:ss a z') },
    },
    {
      Header: 'Booked by',
      Cell: (row) => {
        if (row.user_id === null) {
          if (this.props.user_id === null || !this.props.show_buttons) {
            return ''
          } else {
            return (
              <BookingButton
                availability_id={row.availability_id}
                user_id={this.props.user_id}
                show={this.props.show_buttons}
              />
            )
          }
        } else {
          return (
            <div className={'calendar-table-cell'}>
              <a href={Routes.user_path(row.user_id)}>{row.username}</a>
              {row.can_cancel ? <CancelButton booking_id={row.booking_id} user_id={row.user_id} /> : ''}
            </div>
          )
        }
      }
    },
    {
      Header: 'Delete',
      hide: !this.props.delete_availabilities,
      Cell: (row) => {
        if (row.can_delete_availability) {
          return (
            <div className={'calendar-table-cell'}>
              <DeleteButton availability_id={row.availability_id} resource_id={row.resource_id}/>
            </div>
          )
        } else {
          return ''
        }
      }
    }
  ];

  renderHeader = () => {
    return this.columns.map((col, i) => {
      if (!col.hide) {
        return <th key={i} >{col.Header}</th>
      }
    })
  };

  renderCell = (obj, col) => {
    if (typeof col.Cell === 'function') {
      return col.Cell(obj);
    } else {
      return obj[col.accessor]
    }
  };

  renderRows = () => {
    return this.props.data.map((obj, i) => {
      return (
        <tr key={i}>
          {this.columns.map((col, j) => {
            if (!col.hide) {
              return <td key={j}>{this.renderCell(obj, col)}</td>
            }})}
        </tr>
      )
    })
  };

  render() {
    return (
      <table className={'calendar-table'}>
        <thead>
          <tr>
            {this.renderHeader()}
          </tr>
        </thead>
        <tbody>
          {this.renderRows()}
        </tbody>
      </table>
    )
  }
}

class BookingButton extends React.Component {

  makeBooking = () => {
    $.post({
      url: Routes.bookings_path(),
      data: {
        availability_id: this.props.availability_id,
        user_id: this.props.user_id
      }
    })
  };

  render() {
    return (
      <button className={'book submit-button'} disabled={!this.props.show} onClick={this.makeBooking}>book now</button>
    )
  }
}

class CancelButton extends React.Component {

  cancelBooking = () => {
    $.ajax({
      type: 'DELETE',
      url: Routes.booking_path(this.props.booking_id)
    })
  };

  render() {
    return (
      <a className={'cancel icon-button'} onClick={this.cancelBooking}>&#10060;</a> // X icon
    )
  }
}

class DeleteButton extends React.Component {

  deleteAvailability = () => {
    $.ajax({
      type: 'DELETE',
      url: Routes.resource_availability_path(this.props.resource_id, this.props.availability_id)
    })
  };

  render() {
    return (
      <a className={'delete icon-button'} onClick={this.deleteAvailability}>&#10060;</a> // X icon
    )
  }
}

export default BookingsCalendar;
