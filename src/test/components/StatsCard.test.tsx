import { render, screen } from '@testing-library/react'
import { describe, expect, it } from 'vitest'
import { UserGroupIcon } from '@heroicons/react/24/outline'
import StatsCard from '../../components/Dashboard/StatsCard'

describe('StatsCard', () => {
  const mockProps = {
    name: 'Total Students',
    value: 1250,
    icon: UserGroupIcon,
    color: 'bg-blue-100',
    change: '+12.5%',
    changeType: 'positive' as const
  }

  it('renders with correct name and value', () => {
    render(<StatsCard {...mockProps} />)
    
    expect(screen.getByText('Total Students')).toBeInTheDocument()
    // El componente formatea el número como 1,250
    expect(screen.getByText('1,250')).toBeInTheDocument()
  })

  it('displays change correctly', () => {
    render(<StatsCard {...mockProps} />)
    
    expect(screen.getByText('+12.5%')).toBeInTheDocument()
  })

  it('renders with negative change', () => {
    const negativeProps = {
      ...mockProps,
      change: '-5.2%',
      changeType: 'negative' as const
    }
    
    render(<StatsCard {...negativeProps} />)
    expect(screen.getByText('-5.2%')).toBeInTheDocument()
  })

  it('shows loading state', () => {
    render(<StatsCard {...mockProps} isLoading={true} />)
    expect(screen.getByText('Total Students')).toBeInTheDocument()
  })
})
